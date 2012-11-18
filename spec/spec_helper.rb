# encoding: UTF-8

require 'bundler'

Bundler.setup

unless defined?(Rubinius)
  require 'simplecov'
  SimpleCov.start do
    add_filter "/spec/"
  end
end

require 'rspec'
require 'pry'
require 'bit_set'