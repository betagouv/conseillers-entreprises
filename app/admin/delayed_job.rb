require 'delayed/backend/active_record'

ActiveAdmin.register Delayed::Backend::ActiveRecord::Job, as: 'Jobs' do
  menu priority: 2
  actions :index, :show, :destroy

  # Index
  #
  index do
    selectable_column
    id_column
    column :failed_at
    column :name
    column :attempts
    column :status do |job|
      if job.failed_at.present?
        status_tag('Failed:', class: :no)
        span "#{job.last_error[0..100]}"
      elsif job.locked_at.present?
        status_tag(:Running, class: :no)
        span "Depuis #{time_ago_in_words(job.locked_at)} @ #{job.locked_by}"
      elsif job.run_at > job.created_at
        status_tag(:Scheduled, class: :yes)
        span "Dans #{time_ago_in_words(job.run_at)}"
      else
        status_tag :Queued
        span "Depuis #{time_ago_in_words(job.created_at)}"
      end
    end

    actions defaults: true, dropdown: true do |job|
      item('Relancer', retry_admin_job_path(job), method: :post)
    end
  end

  action_item :retry, only: :show do
    link_to('Relancer', retry_admin_job_path(resource), method: :post)
  end

  batch_action 'Relancer' do |ids|
    batch_action_collection.find(ids).each do |job|
      job.update(run_at: job.created_at, attempts: 0, failed_at: nil)
    end
    redirect_back fallback_location: collection_path, notice: 'Jobs re-planifiés'
  end

  # Show
  #
  show do |job|
    attributes_table(*(default_attribute_table_rows - [:handler, :last_error])) do
      row(:handler) { simple_format(job.handler) rescue '' }
      row(:last_error) { simple_format(job.last_error) rescue '' }
    end
  end

  # Actions
  #
  member_action :retry, method: :post do
    job = resource
    job.update(run_at: job.created_at, attempts: 0, failed_at: nil)
    redirect_back fallback_location: collection_path, notice: 'Job re-planifié'
  end
end
