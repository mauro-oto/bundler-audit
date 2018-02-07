require 'bundler/audit/results'

module Bundler
  module Audit
    #
    # Represents the result of a scan.
    #
    class Report

      include Enumerable

      # The list of all results.
      #
      # @return [Array<Results::Result>]
      attr_reader :results

      # The insecure sources results.
      #
      # @return [Array<Results::InsecureSources>]
      attr_reader :insecure_sources

      # The unpatched gems results.
      #
      # @return [Array<Results::UnpatchedGems>]
      attr_reader :unpatched_gems

      #
      # Initializes the report.
      #
      # @param [#each] results
      #
      def initialize(results=[])
        @results = []
        @insecure_sources = []
        @unpatched_gems = []

        results.each { |result| self << result }
      end

      #
      # Enumerates over the results.
      #
      # @yield [result]
      #
      # @yieldparam [Results::InsecureSource, Results::UnpatchedGem] result
      #
      # @return [Enumerator]
      #
      def each(&block)
        @results.each(&block)
      end

      #
      # Appends a result to the report.
      #
      # @param [InsecureSource, UnpatchedGem] result
      #
      def <<(result)
        @results << result

        case result
        when Results::InsecureSource
          @insecure_sources << result
        when Results::UnpatchedGem
          @unpatched_gems << result
        end

        return self
      end

      #
      # Determines if there were vulnerabilities found.
      #
      # @return [Boolean]
      #
      def vulnerable?
        !@results.empty?
      end

      #
      # @yield [advisory]
      #
      # @yieldparam [Advisory] advisory
      #
      # @return [Enumerator]
      #
      def each_advisory
        return enum_for(__method__) unless block_given?

        @unpatched_gems.each { |result| yield result.advisory }
      end

      #
      # @return [Array<Advisory>]
      #
      def advisories
        @unpatched_gems.map(&:advisory)
      end

      #
      # @yield [gem]
      #
      # @yieldparam [Gem::Specification]
      #
      # @return [Enumerator]
      #
      def each_vulnerable_gem
        return enum_for(__method__) unless block_given?

        @unpatched_gems.each { |result| yield result.gem }
      end

      #
      # @return [Array<Gem::Specification>]
      #
      def vulnerable_gems
        @unpatched_gems.map(&:gem)
      end

    end
  end
end
