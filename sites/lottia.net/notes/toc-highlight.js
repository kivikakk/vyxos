window.addEventListener('DOMContentLoaded', () => {
    const observer = new IntersectionObserver(entries => {
        entries.forEach(entry => {
            let id = entry.target.getAttribute('id');
            if (id == 'opening') { id = 'top'; }

            const element = document.querySelector(`.toc a[href="#${id}"]`);
            if (!element) { return; }

            if (entry.intersectionRatio > 0) {
                element.parentElement.classList.add('on-screen');
            } else {
                element.parentElement.classList.remove('on-screen');
            }
        });

        let activated = false;
        document.querySelectorAll('.toc li.active, .toc li.on-screen').forEach(li => {
            if (!li.classList.contains('on-screen')) {
                li.classList.remove('active');
            } else if (!activated) {
                li.classList.add('active');
                activated = true;
            } else {
                li.classList.remove('active');
            }
        })
    });

    document.querySelectorAll('section[id]').forEach(el => {
        observer.observe(el);
    });
});
