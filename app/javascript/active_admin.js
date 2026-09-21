// Entry point of the /admin bundle, built by esbuild alongside the public ones.
//
// ActiveAdmin 4 documents importmap for this, but the app already bundles all of
// its JavaScript with esbuild, so the admin assets go through the same pipeline
// rather than introducing a second one. The head partial is overridden in
// app/views/active_admin/_html_head.html.erb to load this build.
import '@activeadmin/activeadmin';

import './admin/ajax_select';
import './admin/quill_editor';
import './admin/reorderable';
import './admin/custom';
