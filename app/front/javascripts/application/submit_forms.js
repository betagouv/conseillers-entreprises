// fonction utilisée pour submit le formulaire de choix de territoires au changement du select
document.addEventListener("turbo:load", function() {
  const territorySelect = document.getElementById("territory")
  if (territorySelect !== null) {
    territorySelect.onchange = function(){
      this.form.submit()
    };
  }
});
