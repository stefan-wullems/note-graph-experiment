// Active should be the source of truth

customElements.define('snap-row', class extends HTMLElement {

    static get observedAttributes() {
        return ['activeIndex']
    }

    get items() {
        return this.querySelectorAll('snap-item')
    }

    calcActiveIndex() {
        let scroll = this.scrollLeft
        let activeIndex = -1

        this.items.forEach((item, index) => {
            if (activeIndex !== -1) return
            if ((scroll -= item.clientWidth) < 0) {
                activeIndex = index
            }
        })

        return activeIndex
    }

    get activeIndex() {
        return Number(this.getAttribute('activeIndex'))
    }

    set activeIndex(val) {
        this.setAttribute('activeIndex', String(val))
        this.dispatchEvent(new CustomEvent('changeActiveIndex'))

    }

    attributeChangedCallback(name, prevValue, value) {
        switch (name) {
            case 'activeIndex': {
                this.invalidateScroll()
            }
        }
    }

    invalidateScroll() {
        console.log(this.items[this.activeIndex], this.activeIndex)
        const item = this.items[this.activeIndex]
        console.log(item)
        if (item) {
            const rect = item.getBoundingClientRect()
            console.log(rect.x)
            this.scrollTo({ left: this.activeIndex * rect.x, behavior: 'smooth' })
        }


    }

    connectedCallback() {
        this.addEventListener('scroll', () => {
            const currActiveIndex = this.calcActiveIndex()
            if (currActiveIndex !== this.activeIndex) {
                this.activeIndex = currActiveIndex
            }

        }, false);
    }

})

customElements.define('snap-item', class extends HTMLElement {
    connectedCallback() {
        this.parentElement.invalidateScroll()
    }
})

customElements.define("snap-bound", class extends HTMLElement {

})