(function () {
  addEventListener('turbolinks:load', function() {
    console.log('yop')
    let feedbackLinks = document.getElementsByClassName( 'show-feedbacks-form' )
    for ( let i = 0; i < feedbackLinks.length; i++ ) {
      const feedbackLink = feedbackLinks[i];
      feedbackLink.onclick = function() {
        const feedbackableId = feedbackLink.dataset.feedbackable
        const forms = document.getElementsByClassName("feedback-form-" + feedbackableId)
        forms.forEach(form => form.style.display = 'block');
      }
    }
  })
})()
