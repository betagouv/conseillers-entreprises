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
})