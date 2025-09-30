# frozen_string_literal: true

# Disable zip64 globally to make our Excel exports compatible with Google Sheets.
# See https://github.com/betagouv/conseillers-entreprises/issues/4008.
# Remove once https://github.com/caxlsx/caxlsx/pull/482 is resolved.
Zip.write_zip64_support = false
