document.addEventListener("DOMContentLoaded", function() {

  // Formulaire édition utilisateur
  // Affiche confirmation si on attribue le rôle Admin
  const edit_user_rights_block = document.querySelector('.user_rights');
  if(typeof edit_user_rights_block !== 'undefined' && edit_user_rights_block != null) {
    // les droits peuvent être créé dynamiquement, on délègue l'event au block supérieur
    edit_user_rights_block.addEventListener("change", function(event) {
      if (event.target.tagName.toLowerCase() === 'select' && event.target.value === 'admin') {
        var response = confirm("Voulez-vous vraiment donner des droits admin à cet(te) utilisateur.rice ?");
        if(response) { return true; }
        event.target.value = 'manager';
        return false;
      }
    })
  }

  // Formulaire édition expert
  // Affiche confirmation si on attribue global_zone
  const expert_is_global_zone_input = document.querySelector('#expert_is_global_zone');
  if(typeof expert_is_global_zone_input !== 'undefined' && expert_is_global_zone_input != null) {
    expert_is_global_zone_input.addEventListener("change", function() {
      if (expert_is_global_zone_input.checked == true) {
        var response = confirm("Voulez-vous vraiment attribuer un territoire national à cet expert ?");
        if(response) { return true; }
        expert_is_global_zone_input.checked = false;
        return false;
      }
    })
  }
})