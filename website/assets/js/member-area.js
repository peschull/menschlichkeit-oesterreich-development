/* Member Area logic (externalized to avoid inline JS for CSP) */
(function () {
  document.addEventListener('DOMContentLoaded', function () {
    if (!window.crmApi || !window.crmApi.isLoggedIn()) {
      window.location.href = 'login.html';
      return;
    }

    initSidebarNavigation();
    initMobileSidebar();
    initProfileForm();
    loadUserData();
  });

  function initSidebarNavigation() {
    const navLinks = document.querySelectorAll('[data-section]');
    const sections = document.querySelectorAll('.content-section');
    navLinks.forEach((link) => {
      link.addEventListener('click', function (e) {
        e.preventDefault();
        const target = this.getAttribute('data-section');
        navLinks.forEach((n) => n.classList.remove('active'));
        this.classList.add('active');
        sections.forEach((s) => s.classList.add('d-none'));
        const el = document.getElementById(`${target}-section`);
        if (el) el.classList.remove('d-none');
        if (window.innerWidth < 992) {
          document.getElementById('memberSidebar')?.classList.remove('show');
          document.getElementById('sidebarOverlay')?.classList.remove('show');
        }
      });
    });
  }

  function initMobileSidebar() {
    const sidebarToggle = document.getElementById('sidebarToggle');
    const sidebar = document.getElementById('memberSidebar');
    const overlay = document.getElementById('sidebarOverlay');
    if (!sidebarToggle || !sidebar || !overlay) return;
    sidebarToggle.addEventListener('click', function () {
      sidebar.classList.toggle('show');
      overlay.classList.toggle('show');
    });
    overlay.addEventListener('click', function () {
      sidebar.classList.remove('show');
      overlay.classList.remove('show');
    });
  }

  function initProfileForm() {
    const form = document.getElementById('profileForm');
    if (!form) return;
    form.addEventListener('submit', async function (e) {
      e.preventDefault();
      const submitBtn = form.querySelector('button[type="submit"]');
      const original = submitBtn?.innerHTML;
      if (submitBtn) {
        submitBtn.innerHTML = '<span class="spinner-border spinner-border-sm me-2"></span>Speichert...';
        submitBtn.disabled = true;
      }
      const data = Object.fromEntries(new FormData(form));
      try {
        const res = await window.crmApi.updateUserProfile(data);
        if (res?.success) {
          showAlert('Profil erfolgreich aktualisiert!', 'success');
        } else {
          showAlert('Fehler beim Aktualisieren des Profils.', 'danger');
        }
      } catch (e) {
        console.error(e);
        showAlert('Unerwarteter Fehler bei der Aktualisierung.', 'danger');
      } finally {
        if (submitBtn) {
          submitBtn.innerHTML = original;
          submitBtn.disabled = false;
        }
      }
    });
  }

  async function loadUserData() {
    try {
      const res = await window.crmApi.getUserProfile();
      if (!res?.success) return;
      const user = res.data || {};
      updateUserInterface(user);
    } catch (e) {
      console.error('Profil laden fehlgeschlagen', e);
    }
  }

  function updateUserInterface(user) {
    const ids = ['userName', 'sidebarUserName', 'welcomeUserName'];
    ids.forEach((id) => {
      const el = document.getElementById(id);
      if (el) el.textContent = user.first_name || 'Mitglied';
    });
    setValue('firstName', user.first_name);
    setValue('lastName', user.last_name);
    setValue('email', user.email);
    setValue('phone', user.phone);
    setValue('address', user.address);
  }

  function setValue(id, val) {
    if (!val) return;
    const el = document.getElementById(id);
    if (el) el.value = val;
  }

  function showAlert(message, type) {
    const box = document.createElement('div');
    box.className = `alert alert-${type} alert-dismissible fade show position-fixed`;
    box.style.cssText = 'top: 100px; right: 20px; z-index: 9999; min-width: 300px;';
    box.innerHTML = `${message}<button type="button" class="btn-close" data-bs-dismiss="alert"></button>`;
    document.body.appendChild(box);
    setTimeout(() => box.remove(), 5000);
  }

  // Logout
  document.addEventListener('DOMContentLoaded', function () {
    const btn = document.getElementById('logoutBtn');
    if (btn) {
      btn.addEventListener('click', function (e) {
        e.preventDefault();
        window.crmApi.logout();
      });
    }
  });
})();

