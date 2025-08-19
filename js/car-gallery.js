  const preview = document.getElementById('preview');
  const thumbnails = document.querySelectorAll('.thumb');

  thumbnails.forEach((thumb, index) => {
    thumb.addEventListener('click', () => {
      // Update preview
      preview.src = thumb.src;

      // Remove active styles
      thumbnails.forEach(t => {
        t.classList.remove('opacity-100', 'border-2', 'border-blue-500');
        t.classList.add('opacity-60');
      });

      // Add active styles to clicked one
      thumb.classList.remove('opacity-60');
      thumb.classList.add('opacity-100', 'border-2', 'border-blue-500');
    });
  });