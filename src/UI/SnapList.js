// -- List: snap-x snap-mandatory
// -- Item: snap-center snap-always
// -- (List.concat
// --     [ [ Html.li [ Attributes.class "snap-center w-1/2 -mr-72 shrink-0" ] [] ]
// --     , List.map (\id -> viewZettel (id == focusId) zettelkasten id) ids
// --     , [ Html.li [ Attributes.class "snap-center w-1/2 -ml-72 shrink-0" ] [] ]
// --     ]
// -- )


customElements.define('snap-row', class extends HTMLElement {
    connectedCallback() {
        var timer = null;
        this.addEventListener('scroll', () => {

            if (timer !== null) {
                clearTimeout(timer);
            }
            timer = setTimeout(() => {



                let scroll = this.scrollLeft
                this.querySelectorAll('snap-item').forEach(item => {
                    if (scroll < 0) return
                    if ((scroll -= item.clientWidth) < 0) {
                        console.log(scroll)
                        item.dispatchEvent(new CustomEvent('snap'))
                    }

                })
            }, 50);
        }, false);
    }
})

customElements.define('snap-item', class extends HTMLElement {

})

customElements.define("snap-bound", class extends HTMLElement {

})