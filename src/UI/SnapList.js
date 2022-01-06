

customElements.define('snap-row', class extends HTMLElement {

    constructor() {
        super()
        this.autoscrolling = false
        this.manuallyScrolling = false
    }


    static get observedAttributes() {
        return ['activeindex']
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
        return Number(this.getAttribute('activeindex'))
    }

    set activeIndex(val) {
        if (!this.autoscrolling) {
            this.setAttribute('activeindex', String(val))
            this.dispatchEvent(new CustomEvent('changeActiveIndex'))
        }
    }

    attributeChangedCallback(name, prevValue, value) {
        switch (name) {
            case 'activeindex': {
                if (!this.manuallyScrolling) {
                    this.invalidateScroll()
                }
            }
        }
    }

    invalidateScroll() {
        const item = this.items[this.activeIndex]

        if (item) {
            const rect = item.getBoundingClientRect()
            this.autoscrolling = true
            requestAnimationFrame(() => {
                this.scrollTo({ left: this.activeIndex * rect.x, behavior: 'smooth' })
                this.autoscrolling = false
            })

        }
    }

    connectedCallback() {
        let timer = null
        this.addEventListener('scroll', () => {
            if (timer !== null) {
                clearTimeout(timer)
            }

            this.manuallyScrolling = true

            timer = setTimeout(() => {
                this.manuallyScrolling = false
            }, 10)

            const calculatedActiveIndex = this.calcActiveIndex()
            if (calculatedActiveIndex !== this.activeIndex) {
                this.activeIndex = calculatedActiveIndex
            }
        }, false);
    }

})

customElements.define('snap-item', class extends HTMLElement {
    connectedCallback() {
        // this.parentElement.invalidateScroll()
    }
})

customElements.define("snap-bound", class extends HTMLElement {

})