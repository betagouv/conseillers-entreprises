function checkboxes_require_one(selector, message) {
  let boxes_parent = document.querySelector(selector);

  function updateBoxesValidity() {
    let at_least_one_checked = !!boxes_parent.querySelector("input[type=checkbox]:checked");
    let validity = at_least_one_checked ? "" : message;
    let boxes = boxes_parent.querySelectorAll("input[type=checkbox]");
    boxes.forEach(function(box) { box.setCustomValidity(validity); });
  }

  boxes_parent.addEventListener("click", function(event) { if (event.target.matches("input[type=checkbox]")) { updateBoxesValidity(); } });

  updateBoxesValidity();
}
