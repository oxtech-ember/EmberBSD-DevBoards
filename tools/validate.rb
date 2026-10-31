#!/usr/bin/env ruby
# Validate the catalog offline. This checker supports only the schema keywords
# used by this repository. It is not a general JSON Schema implementation.
require 'json'
require 'date'
require 'uri'
require 'pathname'

class CatalogValidator
  attr_reader :errors

  def initialize(root)
    @root = File.realpath(root)
    @errors = []
    @records = {}
    @source_ids = []
  end

  def check(condition, message)
    @errors << message unless condition
  end

  def read(path)
    full = local_path(path)
    return nil unless full
    @records[path] ||= JSON.parse(File.read(full))
  rescue JSON::ParserError => e
    @errors << "#{path}: invalid JSON: #{e.message}"
    nil
  end

  def local_path(path)
    unless path.is_a?(String) && !path.empty? && !Pathname.new(path).absolute?
      @errors << "Invalid repository path: #{path.inspect}"
      return nil
    end
    full = File.expand_path(path, @root)
    unless full.start_with?(@root + '/') && File.file?(full) && File.realpath(full).start_with?(@root + '/')
      @errors << "Missing or escaping repository file: #{path}"
      return nil
    end
    full
  end

  def schema(value, spec, label)
    if spec.key?('oneOf')
      matches = spec['oneOf'].count do |branch|
        saved = @errors
        @errors = []
        schema(value, branch, label)
        match = @errors.empty?
        @errors = saved
        match
      end
      check(matches == 1, "#{label}: must match exactly one profile schema")
      return
    end
    check(value == spec['const'], "#{label}: incorrect constant") if spec.key?('const')
    check(spec['enum'].include?(value), "#{label}: invalid vocabulary value") if spec.key?('enum')
    types = {'object'=>Hash,'array'=>Array,'string'=>String,'integer'=>Integer,'number'=>Numeric,'null'=>NilClass}
    if spec['type'] && !Array(spec['type']).any? { |t| value.is_a?(types.fetch(t)) }
      @errors << "#{label}: incorrect type"
      return
    end
    if value.is_a?(Hash)
      Array(spec['required']).each { |key| check(value.key?(key), "#{label}: missing #{key}") }
      check(value.size >= spec['minProperties'], "#{label}: empty object") if spec['minProperties']
      value.each do |key, item|
        child = spec.fetch('properties', {})[key]
        if child
          schema(item, child, "#{label}.#{key}")
        elsif spec['additionalProperties'] == false
          @errors << "#{label}: unknown field #{key}"
        elsif spec['additionalProperties'].is_a?(Hash)
          schema(item, spec['additionalProperties'], "#{label}.#{key}")
        end
      end
    elsif value.is_a?(Array)
      check(value.size >= spec['minItems'], "#{label}: too few items") if spec['minItems']
      check(value.uniq == value, "#{label}: duplicate items") if spec['uniqueItems']
      value.each_with_index { |item, i| schema(item, spec['items'], "#{label}[#{i}]") } if spec['items']
    elsif value.is_a?(String)
      check(value.size >= spec['minLength'], "#{label}: empty string") if spec['minLength']
      check(Regexp.new(spec['pattern']).match?(value), "#{label}: invalid pattern") if spec['pattern']
      if spec['format'] == 'date'
        begin
          check(Date.iso8601(value).iso8601 == value, "#{label}: invalid date")
        rescue ArgumentError
          @errors << "#{label}: invalid date"
        end
      elsif spec['format'] == 'uri'
        begin
          uri = URI.parse(value)
          check(uri.is_a?(URI::HTTPS) && uri.host && !uri.host.empty?, "#{label}: expected HTTPS URL")
        rescue URI::InvalidURIError
          @errors << "#{label}: invalid URI"
        end
      end
    elsif value.is_a?(Numeric) && spec['minimum']
      check(value >= spec['minimum'], "#{label}: below minimum")
    end
  end

  def unique(values, label)
    check(values.uniq == values, "#{label}: duplicate IDs or contacts")
  end

  def source_refs(record, label)
    case record
    when Hash
      record.each do |key, value|
        if key == 'source_refs'
          Array(value).each { |ref| check(@source_ids.include?(ref), "#{label}: unknown source #{ref}") }
        else
          source_refs(value, label)
        end
      end
    when Array
      record.each { |value| source_refs(value, label) }
    end
  end

  def run
    sources = read('sources.json')
    catalog = read('catalog.json')
    return @errors unless sources.is_a?(Hash) && catalog.is_a?(Hash)
    check(sources['format_version'] == 1 && catalog['format_version'] == 1, 'Unsupported catalog version')
    list = sources['sources']
    unless list.is_a?(Array) && !list.empty?
      @errors << 'sources.json: missing sources'
      return @errors
    end
    source_spec = {'type'=>'object','required'=>%w[id title url revision reviewed_at sha256], 'properties'=>{
      'id'=>{'type'=>'string','pattern'=>'^[a-z0-9]+(?:-[a-z0-9]+)*$'}, 'title'=>{'type'=>'string','minLength'=>1},
      'url'=>{'type'=>'string','format'=>'uri'}, 'revision'=>{'type'=>['string','null']},
      'reviewed_at'=>{'type'=>'string','format'=>'date'},'sha256'=>{'type'=>['string','null'],'pattern'=>'^[a-f0-9]{64}$'}}}
    list.each { |s| schema(s, source_spec, 'source') }
    return @errors unless list.all? { |s| s.is_a?(Hash) }
    @source_ids = list.map { |s| s['id'] }
    unique(@source_ids, 'sources')
    groups = %w[boards carriers socs]
    groups.each { |g| check(catalog[g].is_a?(Array), "catalog: missing #{g}") }
    return @errors unless groups.all? { |g| catalog[g].is_a?(Array) }
    entries = groups.flat_map { |g| catalog[g] }
    return @errors << 'catalog: invalid entry' unless entries.all? { |e| e.is_a?(Hash) }
    ids = entries.map { |e| e['id'] }
    ids.each { |id| schema(id, {'type'=>'string','pattern'=>'^[a-z0-9]+(?:-[a-z0-9]+)*$'}, 'catalog ID') }
    unique(ids, 'catalog')
    board_ids = catalog['boards'].map { |e| e['id'] }
    carrier_ids = catalog['carriers'].map { |e| e['id'] }
    soc_ids = catalog['socs'].map { |e| e['id'] }
    unique(board_ids + catalog['boards'].flat_map { |e| Array(e['aliases']) }, 'board aliases')
    profile_schema = read('schemas/profile.schema.json')
    indexed_profiles = (catalog['boards'] + catalog['carriers']).map { |e| e['profile'] }
    found_profiles = Dir.glob(File.join(@root, '{boards/*/board,carriers/*/carrier}.json')).map do |path|
      Pathname.new(path).relative_path_from(Pathname.new(@root)).to_s
    end
    check(indexed_profiles.sort == found_profiles.sort, 'catalog: missing or extra profile index')
    entries.each do |entry|
      if entry['document']
        local_path(entry['document'])
        next
      end
      record = read(entry['profile'])
      next unless record.is_a?(Hash) && profile_schema
      before = @errors.length
      schema(record, profile_schema, entry['id'])
      next unless @errors.length == before
      check(record['id'] == entry['id'], "#{entry['id']}: profile ID differs")
      source_refs(record, entry['id'])
      record.fetch('documents', {}).each_value { |path| local_path(path) }
      if record['kind'] == 'carrier'
        Array(record['module_ids']).each do |id|
          module_entry = catalog['boards'].find { |item| item['id'] == id }
          module_profile = module_entry && @records[module_entry['profile']]
          check(module_profile && module_profile['kind'] == 'module', "Unknown module #{id}")
          check(module_profile && Array(module_profile['carrier_ids']).include?(record['id']), "#{id}: carrier link is not reciprocal")
        end
        connectors = Array(record['connectors'])
        unique(connectors.map { |c| c['id'] }, entry['id'])
        connectors.each { |c| unique(Array(c['pins']).map { |p| p['contact'] }, "#{entry['id']}/#{c['id']}") }
      else
        check(soc_ids.include?(record['soc']), "#{entry['id']}: unknown SoC")
        Array(record['carrier_ids']).each { |id| check(carrier_ids.include?(id), "Unknown carrier #{id}") }
        unique(Array(record['capabilities']).map { |c| c['id'] }, entry['id'])
      end
    end
    record_ids = []
    {'config'=>'boards/*/configs/*/manifest.json','evidence'=>'boards/*/evidence/*.json'}.each do |kind, glob|
      spec = read("schemas/#{kind}.schema.json")
      Dir.glob(File.join(@root, glob)).sort.each do |full|
        path = Pathname.new(full).relative_path_from(Pathname.new(@root)).to_s
        record = read(path)
        next unless record.is_a?(Hash) && spec
        before = @errors.length
        schema(record, spec, path)
        next unless @errors.length == before
        source_refs(record, path)
        record_ids << record['id']
        check(board_ids.include?(record['target_id']), "#{path}: unknown target")
        check(path.split('/')[1] == record['target_id'], "#{path}: target differs from containing board")
        if kind == 'config'
          # Git identifies the committed copy; the manifest hash is for
          # downloads from the url and is not compared again here.
          Array(record['files']).each { |file| local_path(file['repository_path']) if file['repository_path'] }
        else
          carrier = record.fetch('hardware', {})['carrier_id']
          check(carrier_ids.include?(carrier), "#{path}: unknown evidence carrier") if carrier
          Array(record['inputs']).each { |input| local_path(input['reference']) if input['reference'] }
        end
      end
    end
    unique(record_ids, 'config/evidence records')
    # Check local Markdown file targets. Anchors and remote resources need review.
    Dir.glob(File.join(@root, '**/*.md')).each do |full|
      relative = Pathname.new(full).relative_path_from(Pathname.new(@root)).to_s
      File.read(full).scan(/\]\(([^\s)]+)(?:\s+"[^"]*")?\)/).flatten.each do |target|
        next if target.start_with?('#') || target.match?(/\A[a-z][a-z0-9+.-]*:/i)
        target = target.split('#', 2).first
        local_path(Pathname.new(File.join(File.dirname(relative), target)).cleanpath.to_s)
      end
    end
    @errors
  end
end

if $PROGRAM_NAME == __FILE__
  abort 'Usage: ruby tools/validate.rb [repository-root]' if ARGV.size > 1
  validator = CatalogValidator.new(ARGV[0] || File.expand_path('..', __dir__))
  errors = validator.run
  if errors.empty?
    puts 'PASS: profiles, references and local Markdown targets'
  else
    warn errors.join("\n")
    exit 1
  end
end
