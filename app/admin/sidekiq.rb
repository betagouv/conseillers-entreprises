ActiveAdmin.register_page "Jobs" do
  menu priority: 10

  content do
    iframe src: "/admin/sidekiq", style: "width: 100%; height: 100vh;"
  end
end
