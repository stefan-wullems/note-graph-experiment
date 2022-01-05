customElements.define('snap-row', class extends HTMLElement {
    connectedCallback() {

        this.addEventListener('scroll', () => {


            let scroll = this.scrollLeft
            this.querySelectorAll('snap-item').forEach(item => {
                if (scroll < 0) return
                if ((scroll -= item.clientWidth) < 0) {
                    console.log(scroll)
                    item.dispatchEvent(new CustomEvent('snap'))
                }

            })

        }, false);
    }
})

customElements.define('snap-item', class extends HTMLElement {

})

customElements.define("snap-bound", class extends HTMLElement {

})