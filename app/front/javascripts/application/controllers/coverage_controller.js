import { Controller } from 'stimulus'

export default class extends Controller {
  loadSingle(event) {
    const button = event.currentTarget
    const institutionSubjectId = button.dataset.institutionSubjectId
    const antenneId = button.dataset.antenneId
    const iconElement = button.querySelector('span')

    this.setLoadingState(button, iconElement, true)
    
    const institutionSlug = this.getInstitutionSlug()
    if (!institutionSlug) {
      this.setLoadingState(button, iconElement, false)
      return
    }
    
    // Load the coverage for this specific institution_subject
    const frame = document.getElementById(`institution-subject-${institutionSubjectId}`)
    const url = `/annuaire/institutions/${institutionSlug}/conseillers/create_territorial_coverage?institution_subject_id=${institutionSubjectId}&antenne_id=${antenneId}`
    
    fetch(url, {
      headers: {
        'Accept': 'text/html',
        'X-Requested-With': 'XMLHttpRequest',
        'X-CSRF-Token': this.getCSRFToken()
      }
    })
    .then(response => {
      if (!response.ok) {
        throw new Error(`HTTP error! status: ${response.status}`)
      }
      return response.text()
    })
    .then(html => {
      frame.innerHTML = html
    })
    .catch(error => {
      this.setLoadingState(button, iconElement, false)
    })
  }

  loadAll(event) {
    const button = event.currentTarget
    const antenneId = button.dataset.antenneId
    
    const institutionSlug = this.getInstitutionSlug()
    if (!institutionSlug) {
      return
    }
    
    // Disable button and show loading state
    button.disabled = true
    const originalContent = button.innerHTML
    const loadingText = button.dataset.loadingText || 'Chargement en cours...'
    button.innerHTML = `<span class="ri-loader-4-line ri-spin fr-mr-1v"></span>${loadingText}`
    
    // Find all lazy coverage containers and load them
    const lazyContainers = document.querySelectorAll('.lazy-coverage-container')
    let loadedCount = 0
    const totalCount = lazyContainers.length

    // Load each coverage individually with a small delay to avoid overwhelming the server
    const loadNext = (index) => {
      if (index >= totalCount) {
        // All loaded, restore button
        button.disabled = false
        button.innerHTML = originalContent
        return
      }
      
      const container = lazyContainers[index]
      const institutionSubjectId = container.dataset.institutionSubjectId
      const frame = document.getElementById(`institution-subject-${institutionSubjectId}`)
      const url = `/annuaire/institutions/${institutionSlug}/conseillers/create_territorial_coverage?institution_subject_id=${institutionSubjectId}&antenne_id=${antenneId}`
      
      fetch(url, {
        headers: {
          'Accept': 'text/html',
          'X-Requested-With': 'XMLHttpRequest',
          'X-CSRF-Token': this.getCSRFToken()
        }
      })
      .then(response => {
        if (!response.ok) {
          throw new Error(`HTTP error! status: ${response.status}`)
        }
        return response.text()
      })
      .then(html => {
        frame.innerHTML = html
        loadedCount++
        
        // Update progress
        const progress = Math.round((loadedCount / totalCount) * 100)
        const progressText = button.dataset.progressText || 'Chargement... %{progress}%'
        const displayText = progressText.replace('%{progress}', progress)
        button.innerHTML = `<span class="ri-loader-4-line ri-spin fr-mr-1v"></span>${displayText}`
        
        setTimeout(() => loadNext(index + 1), 50)
      })
      .catch(error => {
        loadedCount++
        loadNext(index + 1)
      })
    }
    loadNext(0)
  }

  // Helper methods
  getInstitutionSlug() {
    const pathParts = window.location.pathname.split('/')
    const institutionIndex = pathParts.indexOf('institutions')
    return institutionIndex !== -1 ? pathParts[institutionIndex + 1] : null
  }

  setLoadingState(button, iconElement, isLoading) {
    button.disabled = isLoading
    iconElement.className = isLoading ? 'ri-loader-4-line ri-spin' : 'ri-loader-4-line'
  }

  getCSRFToken() {
    return document.querySelector('meta[name="csrf-token"]')?.content || ''
  }
}