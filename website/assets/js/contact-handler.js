/* Kontaktformular: erzeugt Mailto-Link an die Vereinsadresse */
document.addEventListener('DOMContentLoaded', function () {
  const form = document.getElementById('contactForm');
  if (!form) return;
  form.addEventListener('submit', function (e) {
    e.preventDefault();
    const name = (document.getElementById('name')?.value || '').trim();
    const email = (document.getElementById('email')?.value || '').trim();
    const subject = (document.getElementById('subject')?.value || '').trim();
    const message = (document.getElementById('message')?.value || '').trim();
    const to = 'menschlichkeit-oesterreich@outlook.at';
    const composedSubject = [subject, name].filter(Boolean).join(' - ');
    const body = `Name: ${name}\nE-Mail: ${email}\n\nNachricht:\n${message}`;
    const mailtoLink = `mailto:${to}?subject=${encodeURIComponent(composedSubject)}&body=${encodeURIComponent(body)}`;
    window.location.href = mailtoLink;
  });
});
