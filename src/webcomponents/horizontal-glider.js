import { LitElement, css, html, unsafeCSS } from 'lit-element'
import Glider from 'glider-js'
import gliderCss from "glider-js/glider.css"

const NAME = 'horizontal-glider'
const events = {

}

class HorizontalGlider extends LitElement {

  static styles = css`
    ${unsafeCSS(gliderCss)}
  `

  firstUpdated() {
    this.root = this.shadowRoot.querySelector('.glider')
    new Glider(this.root, { slidesToShow: 3, slidesToScroll: 1, draggable: true })
  }

  renderSlides() {
    console.log(this.children)
    const slides = []
    for (let i = 0; i < this.children.length; i++) {
      slides.push(html`<div><slot name="slide${i}"></slot></div>`)
    }
    return slides
  }

  render() {

    return html`
    <div class="glider-contain">
      <div class="glider">
          ${this.renderSlides()}
      </div>
    </div>
    	`
  }
}

customElements.define('horizontal-glider', HorizontalGlider)

class HorizontalGliderItem extends LitElement {

  firstUpdated() {
    this.parentElement.requestUpdate()
  }

  render() {

    return html`
  
      <slot> </slot>
    	`
  }
}


customElements.define('glider-item', HorizontalGliderItem)