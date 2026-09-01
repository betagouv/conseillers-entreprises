module RecordExtensions
  module InBatchesWithProgress
    ## Display a progress bar in the output (with the ProgressBar gem) when running #in_batches on a relation.
    def in_batches_with_progress(**args)
      bar = ProgressBar.new(size)
      batch_size = args[:of]

      if block_given?
        in_batches(**args){ |batch| yield(batch).tap{ bar.increment!(batch_size) } }
      else
        batch_enumerator = in_batches(**args)
        batch_enumerator.define_singleton_method(:each) do |&block|
          super() { |batch| block.call(batch).tap{ bar.increment!(batch_size) } }
        end
        batch_enumerator
      end
    end
  end
end
