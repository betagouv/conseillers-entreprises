ActiveAdmin.register Delayed::Job, as: "DelayedJob" do
  collection_action :run_all, method: :post do
    successes, failures = Delayed::Worker.new.work_off
    if failures > 0
      flash[:alert] = "#{failures} failed delayed jobs when running them."
    end
    if successes > 0
      flash[:notice] = "#{successes} delayed jobs run successfully"
    end
    if failures == 0 && successes == 0
      flash[:notice] = "Yawn... no delayed jobs run"
    end
    redirect_to admin_delayed_jobs_url
    I18n.locale = :en # Running delayed jobs can mess up the locale.
  end

  if Rails.env.development?
    collection_action :delete_all, method: :post do
      n = Delayed::Job.delete_all
      redirect_to admin_delayed_jobs_url, notice: "#{n} jobs deleted."
    end
  end

  collection_action :mark_all_for_re_run, method: :post do
    n = Delayed::Job.update_all("run_at = created_at")
    redirect_to admin_delayed_jobs_url, notice: "Marked all jobs (#{n}) for re-running."
  end

  member_action :run, method: :post do
    delayed_job = Delayed::Job.find(params[:id])
    begin
      delayed_job.invoke_job
      delayed_job.destroy
      redirect_to admin_delayed_jobs_url, notice: "1 delayed job run, apparently successfully, but who knows!"
    rescue => e
      redirect_to admin_delayed_jobs_url, alert: "Failed to run a delayed job: #{e.to_s}"
    end
    I18n.locale = :en # Running delayed jobs can mess up the locale.
  end

  action_item do
    links = link_to("Run All Delayed Jobs", run_all_admin_delayed_jobs_url, method: :post)
    links += (" " + link_to("Mark all for re-run", mark_all_for_re_run_admin_delayed_jobs_url, method: :post)).html_safe
    links += (" " + link_to("Delete All Delayed Jobs", delete_all_admin_delayed_jobs_url, method: :post)).html_safe if Rails.env.development?
    links
  end

  index do
    selectable_column
    id_column
    column "P", :priority
    column "A", :attempts
    column("Error", :last_error, sortable: :last_error) { |post| post.last_error.present? ? post.last_error.split("\n").first : "" }
    column(:created_at, sortable: :created_at) { |job| job.created_at.iso8601.tr("T", " ") }
    column(:run_at, sortable: :run_at) { |post| post.run_at.present? ? post.run_at.iso8601.tr("T", " ") : nil }
    column :queue
    column("Running", sortable: :locked_at) { |dj| dj.locked_at.present? ? "#{(Time.now - dj.locked_at).round(1)}s by #{dj.locked_by}" : "" }
    actions
  end

  show title: -> (dj) { "Delayed job #{dj.id}" } do |delayed_job|
    panel "Delayed job" do
      attributes_table_for delayed_job do
        row :id
        row :priority
        row :attempts
        row :queue
        row :run_at
        row :locked_at
        row :failed_at
        row :locked_by
        row :created_at
        row :updated_at
      end
    end

    panel "Handler" do
      begin
        pre delayed_job.handler
      rescue => e
        div "Couldn't render handler: #{e.message}"
      end
    end

    panel "Last error" do
      begin
        pre delayed_job.last_error
      rescue => e
        div "Couldn't render last error: #{e.message}"
      end
    end

    active_admin_comments
  end

  form do |f|
    f.inputs("Delayed job") do
      f.input :id, input_html: { readonly: true }
      f.input :priority
      f.input :attempts
      f.input :queue
      f.input :created_at, input_html: { readonly: true }, as: :string
      f.input :updated_at, input_html: { readonly: true }, as: :string
      f.input :run_at, input_html: { readonly: true }, as: :string
      f.input :locked_at, input_html: { readonly: true }, as: :string
      f.input :failed_at, input_html: { readonly: true }, as: :string
      f.input :locked_by, input_html: { readonly: true }
    end

    f.actions
  end

  controller do
    def update
      @delayed_job = Delayed::Job.find(params[:id])
      @delayed_job.assign_attributes(params[:delayed_job], without_protection: true)
      if @delayed_job.save
        redirect_to admin_delayed_jobs_url, notice: "Delayed job #{@delayed_job} saved successfully"
      else
        render :edit
      end
      I18n.locale = :en # Running delayed jobs can mess up the locale.
    end
  end
end
