import { execSync } from 'child_process';
import activeAdminPlugin from '@activeadmin/activeadmin/plugin';

// Always use the last line of output since Bundler's DEBUG env will print additional lines.
const activeAdminPath = execSync('bundle show activeadmin', { encoding: 'utf-8' }).trim().split(/\r?\n/).pop();

export default {
  content: [
    `${activeAdminPath}/vendor/javascript/flowbite.js`,
    `${activeAdminPath}/plugin.js`,
    `${activeAdminPath}/app/views/**/*.{arb,erb,html,rb}`,
    // haml is in there because a couple of admin pages render haml partials,
    // and app/inputs holds the custom Formtastic inputs used by admin forms.
    './app/admin/**/*.{arb,erb,haml,html,rb}',
    './app/inputs/**/*.rb',
    './app/views/active_admin/**/*.{arb,erb,haml,html,rb}',
    './app/views/admin/**/*.{arb,erb,haml,html,rb}',
    './app/views/layouts/active_admin*.{erb,haml,html}',
    './app/javascript/**/*.js'
  ],
  darkMode: 'selector',
  plugins: [
    activeAdminPlugin
  ]
}
