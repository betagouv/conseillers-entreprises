# require 'rails_helper'
#
# describe JobExtensions::RemoveDelayedJobs do
#   describe 'remove_jobs' do
#     before do
#       stub_const('SomeClass', Class.new do
#         def self.a_method; end
#
#         def self.another_method; end
#       end)
#     end
#
#     subject(:remove_delayed_jobs) { ApplicationJob.remove_delayed_jobs(queue, &block) }
#
#     let(:queue) { 'queue' }
#     let(:block) { -> (job) { job.payload_object.method_name == :a_method } }
#
#     context 'one job' do
#       before { SomeClass.delay(queue: 'queue').a_method }
#
#       context 'one job, matching' do
#         it { expect{ remove_delayed_jobs }.to change(Delayed::Job, :count).by(-1) }
#       end
#
#       context 'no queue or block specified' do
#         let(:queue) { nil }
#         let(:block) { nil }
#
#         it { expect{ remove_delayed_jobs }.to change(Delayed::Job, :count).by(-1) }
#       end
#
#       context 'one job, other queue' do
#         let(:queue) { 'another_queue' }
#
#         it { expect{ remove_delayed_jobs }.not_to change(Delayed::Job, :count) }
#       end
#
#       context 'one job, not matching block' do
#         let(:block) { -> (job) { job.payload_object.method_name == 'another_method' } }
#
#         it { expect{ remove_delayed_jobs }.not_to change(Delayed::Job, :count) }
#       end
#     end
#
#     context 'several jobs' do
#       let(:job) { SomeClass.delay(queue: 'queue').a_method }
#
#       before do
#         SomeClass.delay(queue: 'queue').a_method
#         SomeClass.delay(queue: 'queue').a_method
#
#         SomeClass.delay(queue: 'queue').another_method
#         SomeClass.delay(queue: 'another_queue').a_method
#         SomeClass.delay(queue: 'another_queue').another_method
#       end
#
#       it { expect{ remove_delayed_jobs }.to change(Delayed::Job, :count).by(-2) }
#     end
#   end
# end
