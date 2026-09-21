# Formtastic input rendering a Quill rich-text editor.
#
# Replaces the activeadmin_quill_editor gem, which pins activeadmin < 4.
# The editable area is a plain div driven by Quill; the value actually submitted
# lives in a hidden field kept in sync by app/assets/javascripts/admin/quill_editor.js
class QuillEditorInput < Formtastic::Inputs::TextInput
  def to_html
    input_wrapping do
      label_html <<
        template.content_tag(:div, editor_html_options) do
          # No id on the hidden field: the wrapper already carries the one the
          # label points at, and duplicate ids break RGAA 8.2 (valid markup).
          builder.hidden_field(input_name, id: nil) << editable_area
        end
    end
  end

  private

  # NB: deliberately not named wrapper_html_options, which Formtastic already
  # uses for the surrounding <li> and would silently render the editor twice.
  def editor_html_options
    # :rows is meaningless on a div, it only makes sense for the textarea we replace
    input_html_options.except(:rows).merge('data-quill-editor': '')
  end

  def editable_area
    template.content_tag(:div, 'data-quill-content': '', role: 'textbox', 'aria-multiline': 'true') do
      object.send(method).try :html_safe
    end
  end
end
