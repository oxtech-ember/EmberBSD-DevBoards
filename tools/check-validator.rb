#!/usr/bin/env ruby
# Exercise failures that could make a hardware record misleading.
require 'tmpdir'
require 'fileutils'
require_relative 'validate'
root = File.expand_path('..', __dir__)
cases = {
  'SBC as module' => ['carriers/cm5-nano-b/carrier.json', ->(x) { x['module_ids'] = ['bcm2712-rpi5'] }],
  'missing boot document' => ['boards/bcm2712-cm5/board.json', ->(x) { x['documents'].delete('boot') }],
  'missing profile index' => ['catalog.json', ->(x) { x['boards'].pop }],
  'wrong evidence target' => ['boards/bcm2712-cm5/evidence/usb-recovery.json', ->(x) { x['target_id'] = 'a733-zero3w' }],
  'malformed connector' => ['carriers/cm5-nano-b/carrier.json', ->(x) { x['connectors'] = 'not-a-list' }],
  'missing source' => ['boards/bcm2712-cm5/board.json', ->(x) { x['source_refs'] = ['unknown-source'] }],
  'escaping path' => ['catalog.json', ->(x) { x['boards'][0]['profile'] = '../outside.json' }],
  'duplicate alias' => ['catalog.json', ->(x) { x['boards'][1]['aliases'] << 'cm5' }],
  'duplicate pin' => ['carriers/cm5-nano-b/carrier.json', ->(x) { x['connectors'][0]['pins'][1]['contact'] = 6 }],
  'false status' => ['boards/bcm2712-cm5/board.json', ->(x) { x['capabilities'][0]['emberbsd'] = 'fully-supported' }],
  'wrong hash' => ['boards/bcm2712-cm5/configs/usb-recovery/manifest.json', ->(x) { x['files'][0]['sha256'] = '0' * 64 }],
  'unknown carrier' => ['boards/bcm2712-cm5/evidence/usb-recovery.json', ->(x) { x['hardware']['carrier_id'] = 'missing' }],
  'invalid date' => ['boards/bcm2712-cm5/evidence/usb-recovery.json', ->(x) { x['recorded_at'] = '2026-02-30' }]
}
abort 'Baseline does not validate' unless CatalogValidator.new(root).run.empty?
cases.each do |name, (path, mutation)|
  Dir.mktmpdir('devboards-check-') do |copy|
    %w[boards carriers socs interfaces docs schemas templates tools README.md CONTRIBUTING.md catalog.json sources.json].each do |entry|
      FileUtils.cp_r(File.join(root, entry), copy)
    end
    file = File.join(copy, path)
    object = JSON.parse(File.read(file))
    mutation.call(object)
    File.write(file, JSON.generate(object))
    abort "Missed invalid case: #{name}" if CatalogValidator.new(copy).run.empty?
  end
end
puts "PASS: baseline and #{cases.size} invalid-record regressions"
