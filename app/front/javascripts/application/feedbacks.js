(function () {
  addEventListener('turbolinks:load', function() {
    let feedbackLinks = document.getElementsByClassName( 'show-feedbacks-form' )
    for ( let feedbackLink of feedbackLinks ) {
      feedbackLink.onclick = function() {
        let feedbackableId = feedbackLink.dataset.feedbackable
        let form = document.getElementById("feedback-form-" + feedbackableId)
        form.style.display = 'block'
      }
    }
  })
})()
