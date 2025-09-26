/**
 * Main JavaScript für Menschlichkeit Österreich Website
 * Optimiert für Performance, Accessibility und User Experience
 */

/* ===== CONSTANTS & CONFIG ===== */
const CONFIG = {
  scrollOffset: 80,
  animationDuration: 300,
  tooltipDelay: { show: 500, hide: 100 },
  observerOptions: {
    root: null,
    rootMargin: '0px 0px -100px 0px',
    threshold: 0.1,
  },
};

/* ===== UTILITIES ===== */
const Utils = {
  // Throttle function for performance
  throttle: (func, limit) => {
    let inThrottle;
    return function () {
      const args = arguments;
      const context = this;
      if (!inThrottle) {
        func.apply(context, args);
        inThrottle = true;
        setTimeout(() => (inThrottle = false), limit);
      }
    };
  },

  // Debounce function for performance
  debounce: (func, wait, immediate) => {
    let timeout;
    return function () {
      const context = this;
      const args = arguments;
      const later = function () {
        timeout = null;
        if (!immediate) func.apply(context, args);
      };
      const callNow = immediate && !timeout;
      clearTimeout(timeout);
      timeout = setTimeout(later, wait);
      if (callNow) func.apply(context, args);
    };
  },

  // Check if element is in viewport
  isInViewport: element => {
    const rect = element.getBoundingClientRect();
    return (
      rect.top >= 0 &&
      rect.left >= 0 &&
      rect.bottom <= (window.innerHeight || document.documentElement.clientHeight) &&
      rect.right <= (window.innerWidth || document.documentElement.clientWidth)
    );
  },

  // Smooth scroll to element
  smoothScrollTo: (element, offset = CONFIG.scrollOffset) => {
    const targetPosition = element.offsetTop - offset;

    if ('scrollBehavior' in document.documentElement.style) {
      window.scrollTo({
        top: targetPosition,
        behavior: 'smooth',
      });
    } else {
      // Fallback für ältere Browser
      let start = window.pageYOffset;
      let distance = targetPosition - start;
      let duration = CONFIG.animationDuration;
      let startTime = null;

      function animation(currentTime) {
        if (startTime === null) startTime = currentTime;
        let timeElapsed = currentTime - startTime;
        let run = ease(timeElapsed, start, distance, duration);
        window.scrollTo(0, run);
        if (timeElapsed < duration) requestAnimationFrame(animation);
      }

      function ease(t, b, c, d) {
        t /= d / 2;
        if (t < 1) return (c / 2) * t * t + b;
        t--;
        return (-c / 2) * (t * (t - 2) - 1) + b;
      }

      requestAnimationFrame(animation);
    }
  },
};

/* ===== NAVIGATION COMPONENT ===== */
const Navigation = {
  init() {
    this.navbar = document.querySelector('.navbar');
    this.navLinks = document.querySelectorAll('.nav-link[href^="#"]');
    this.sections = document.querySelectorAll('section[id]');

    this.bindEvents();
    this.initActiveStates();

    console.log('Navigation initialized');
  },

  bindEvents() {
    // Smooth scroll für Navigation Links
    this.navLinks.forEach(link => {
      link.addEventListener('click', this.handleNavClick.bind(this));
    });

    // Scroll-basierte Navigation Updates
    window.addEventListener('scroll', Utils.throttle(this.updateActiveNavigation.bind(this), 16));

    // Mobile Navigation Auto-Close
    const navbarToggler = document.querySelector('.navbar-toggler');
    const navbarCollapse = document.querySelector('.navbar-collapse');

    if (navbarToggler && navbarCollapse) {
      this.navLinks.forEach(link => {
        link.addEventListener('click', () => {
          if (navbarCollapse.classList.contains('show')) {
            navbarToggler.click();
          }
        });
      });
    }
  },

  handleNavClick(e) {
    e.preventDefault();
    const targetId = e.currentTarget.getAttribute('href');
    const targetElement = document.querySelector(targetId);

    if (targetElement) {
      Utils.smoothScrollTo(targetElement);

      // Update URL without triggering scroll
      if (history.pushState) {
        history.pushState(null, null, targetId);
      }

      // Accessibility: Focus management
      setTimeout(() => {
        targetElement.setAttribute('tabindex', '-1');
        targetElement.focus();
        targetElement.removeAttribute('tabindex');
      }, CONFIG.animationDuration);
    }
  },

  updateActiveNavigation() {
    let current = '';

    this.sections.forEach(section => {
      const sectionTop = section.offsetTop - CONFIG.scrollOffset - 50;
      const sectionHeight = section.offsetHeight;

      if (window.pageYOffset >= sectionTop && window.pageYOffset < sectionTop + sectionHeight) {
        current = section.getAttribute('id');
      }
    });

    // Update active nav link
    this.navLinks.forEach(link => {
      link.classList.remove('active');
      if (link.getAttribute('href') === `#${current}`) {
        link.classList.add('active');
        link.setAttribute('aria-current', 'page');
      } else {
        link.removeAttribute('aria-current');
      }
    });
  },

  initActiveStates() {
    // Set initial active state
    this.updateActiveNavigation();
  },
};

/* ===== SCROLL ANIMATIONS ===== */
const ScrollAnimations = {
  init() {
    this.observer = null;
    this.animatedElements = document.querySelectorAll(
      '.card, .hero-content, .section-padding > .container'
    );

    if ('IntersectionObserver' in window) {
      this.initIntersectionObserver();
    } else {
      // Fallback für ältere Browser
      this.initScrollFallback();
    }

    console.log('Scroll animations initialized');
  },

  initIntersectionObserver() {
    this.observer = new IntersectionObserver(entries => {
      entries.forEach(entry => {
        if (entry.isIntersecting) {
          entry.target.classList.add('animate-in');

          // Unobserve nach Animation für Performance
          setTimeout(() => {
            this.observer.unobserve(entry.target);
          }, 1000);
        }
      });
    }, CONFIG.observerOptions);

    // Observe all elements
    this.animatedElements.forEach(element => {
      element.classList.add('animate-ready');
      this.observer.observe(element);
    });
  },

  initScrollFallback() {
    const handleScroll = Utils.throttle(() => {
      this.animatedElements.forEach(element => {
        if (Utils.isInViewport(element)) {
          element.classList.add('animate-in');
        }
      });
    }, 16);

    window.addEventListener('scroll', handleScroll);
    handleScroll(); // Initial check
  },
};

/* ===== FORM HANDLING ===== */
const FormHandler = {
  init() {
    this.contactForm = document.querySelector('#contact form');

    if (this.contactForm) {
      this.bindEvents();
      console.log('Form handler initialized');
    }
  },

  bindEvents() {
    this.contactForm.addEventListener('submit', this.handleSubmit.bind(this));

    // Real-time validation
    const inputs = this.contactForm.querySelectorAll('input[required], textarea[required]');
    inputs.forEach(input => {
      input.addEventListener('blur', this.validateField.bind(this));
      input.addEventListener('input', Utils.debounce(this.validateField.bind(this), 300));
    });
  },

  handleSubmit(e) {
    e.preventDefault();

    const formData = new FormData(this.contactForm);
    const isValid = this.validateForm();

    if (isValid) {
      this.submitForm(formData);
    }
  },

  validateForm() {
    const requiredFields = this.contactForm.querySelectorAll('[required]');
    let isValid = true;

    requiredFields.forEach(field => {
      if (!this.validateField({ target: field })) {
        isValid = false;
      }
    });

    return isValid;
  },

  validateField(e) {
    const field = e.target;
    const value = field.value.trim();
    const isValid = this.checkFieldValidity(field, value);

    // Visual feedback
    field.classList.toggle('is-invalid', !isValid);
    field.classList.toggle('is-valid', isValid && value.length > 0);

    // Update ARIA attributes
    field.setAttribute('aria-invalid', !isValid);

    return isValid;
  },

  checkFieldValidity(field, value) {
    if (field.hasAttribute('required') && value.length === 0) {
      return false;
    }

    if (field.type === 'email') {
      const emailPattern = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
      return emailPattern.test(value);
    }

    return true;
  },

  async submitForm(formData) {
    const submitButton = this.contactForm.querySelector('button[type="submit"]');
    const originalText = submitButton.innerHTML;

    // Loading state
    submitButton.disabled = true;
    submitButton.innerHTML = '<i class="bi bi-hourglass-split me-2"></i>Wird gesendet...';

    try {
      // Hier würde normalerweise der API-Call stehen
      await this.simulateFormSubmission(formData);

      // Success state
      submitButton.innerHTML = '<i class="bi bi-check-circle me-2"></i>Erfolgreich gesendet!';
      submitButton.classList.remove('btn-primary');
      submitButton.classList.add('btn-success');

      // Reset form
      setTimeout(() => {
        this.contactForm.reset();
        this.resetFormVisuals();

        submitButton.disabled = false;
        submitButton.innerHTML = originalText;
        submitButton.classList.remove('btn-success');
        submitButton.classList.add('btn-primary');
      }, 3000);
    } catch (error) {
      console.error('Form submission error:', error);

      // Error state
      submitButton.innerHTML =
        '<i class="bi bi-exclamation-triangle me-2"></i>Fehler - Nochmals versuchen';
      submitButton.classList.remove('btn-primary');
      submitButton.classList.add('btn-danger');

      setTimeout(() => {
        submitButton.disabled = false;
        submitButton.innerHTML = originalText;
        submitButton.classList.remove('btn-danger');
        submitButton.classList.add('btn-primary');
      }, 3000);
    }
  },

  async simulateFormSubmission(formData) {
    // Simulation einer API-Anfrage
    return new Promise((resolve, reject) => {
      setTimeout(() => {
        // 90% Erfolgsquote für Demo
        if (Math.random() > 0.1) {
          resolve({ status: 'success', message: 'Form submitted successfully' });
        } else {
          reject(new Error('Network error'));
        }
      }, 2000);
    });
  },

  resetFormVisuals() {
    const fields = this.contactForm.querySelectorAll('.form-control');
    fields.forEach(field => {
      field.classList.remove('is-valid', 'is-invalid');
      field.removeAttribute('aria-invalid');
    });
  },
};

/* ===== UI ENHANCEMENTS ===== */
const UIEnhancements = {
  init() {
    this.initTooltips();
    this.initScrollToTop();
    this.initHoverEffects();
    this.initKeyboardNavigation();

    console.log('UI enhancements initialized');
  },

  initTooltips() {
    // Bootstrap Tooltips
    const tooltipTriggerList = [].slice.call(
      document.querySelectorAll('[data-bs-toggle="tooltip"]')
    );
    tooltipTriggerList.map(function (tooltipTriggerEl) {
      return new bootstrap.Tooltip(tooltipTriggerEl, {
        delay: CONFIG.tooltipDelay,
      });
    });
  },

  initScrollToTop() {
    // Scroll-to-top Button
    const scrollToTopBtn = document.createElement('button');
    scrollToTopBtn.innerHTML = '<i class="bi bi-arrow-up"></i>';
    scrollToTopBtn.className = 'scroll-to-top btn btn-primary rounded-circle position-fixed';
    scrollToTopBtn.style.cssText = `
      bottom: 2rem;
      right: 2rem;
      width: 3rem;
      height: 3rem;
      opacity: 0;
      visibility: hidden;
      transition: all 0.3s ease;
      z-index: 1000;
    `;
    scrollToTopBtn.setAttribute('aria-label', 'Nach oben scrollen');

    document.body.appendChild(scrollToTopBtn);

    // Show/hide based on scroll position
    const toggleScrollButton = Utils.throttle(() => {
      if (window.pageYOffset > 300) {
        scrollToTopBtn.style.opacity = '1';
        scrollToTopBtn.style.visibility = 'visible';
      } else {
        scrollToTopBtn.style.opacity = '0';
        scrollToTopBtn.style.visibility = 'hidden';
      }
    }, 16);

    window.addEventListener('scroll', toggleScrollButton);

    // Scroll to top functionality
    scrollToTopBtn.addEventListener('click', () => {
      Utils.smoothScrollTo(document.body, 0);
    });
  },

  initHoverEffects() {
    // Enhanced hover effects für Cards
    const cards = document.querySelectorAll('.hover-lift');

    cards.forEach(card => {
      card.addEventListener('mouseenter', () => {
        card.style.transform = 'translateY(-5px)';
        card.style.transition = 'transform 0.3s ease, box-shadow 0.3s ease';
      });

      card.addEventListener('mouseleave', () => {
        card.style.transform = 'translateY(0)';
      });
    });
  },

  initKeyboardNavigation() {
    // Skip navigation
    const skipLink = document.querySelector('.skip-navigation');
    if (skipLink) {
      skipLink.addEventListener('click', e => {
        e.preventDefault();
        const target = document.querySelector(skipLink.getAttribute('href'));
        if (target) {
          target.setAttribute('tabindex', '-1');
          target.focus();
        }
      });
    }

    // Keyboard accessibility für custom elements
    document.addEventListener('keydown', e => {
      // ESC key to close mobile menu
      if (e.key === 'Escape') {
        const navbarCollapse = document.querySelector('.navbar-collapse.show');
        if (navbarCollapse) {
          const toggler = document.querySelector('.navbar-toggler');
          if (toggler) toggler.click();
        }
      }
    });
  },
};

/* ===== PERFORMANCE MONITORING ===== */
const Performance = {
  init() {
    this.measureLoadTime();
    this.monitorCoreWebVitals();

    console.log('Performance monitoring initialized');
  },

  measureLoadTime() {
    window.addEventListener('load', () => {
      const loadTime = performance.now();
      console.log(`Page loaded in ${Math.round(loadTime)}ms`);

      // Sende an Analytics (falls vorhanden)
      if (typeof gtag === 'function') {
        gtag('event', 'page_load_time', {
          event_category: 'Performance',
          event_label: 'Load Time',
          value: Math.round(loadTime),
        });
      }
    });
  },

  monitorCoreWebVitals() {
    // Largest Contentful Paint (LCP)
    new PerformanceObserver(entryList => {
      for (const entry of entryList.getEntries()) {
        console.log('LCP:', entry.startTime);
      }
    }).observe({ entryTypes: ['largest-contentful-paint'] });

    // First Input Delay (FID)
    new PerformanceObserver(entryList => {
      for (const entry of entryList.getEntries()) {
        console.log('FID:', entry.processingStart - entry.startTime);
      }
    }).observe({ entryTypes: ['first-input'] });

    // Cumulative Layout Shift (CLS)
    let clsValue = 0;
    new PerformanceObserver(entryList => {
      for (const entry of entryList.getEntries()) {
        if (!entry.hadRecentInput) {
          clsValue += entry.value;
        }
      }
      console.log('CLS:', clsValue);
    }).observe({ entryTypes: ['layout-shift'] });
  },
};

/* ===== MAIN APPLICATION ===== */
const App = {
  init() {
    console.log('Initializing Menschlichkeit Österreich Website...');

    // Warten auf DOM ready
    if (document.readyState === 'loading') {
      document.addEventListener('DOMContentLoaded', this.start.bind(this));
    } else {
      this.start();
    }
  },

  start() {
    try {
      // Initialize all modules
      Navigation.init();
      ScrollAnimations.init();
      FormHandler.init();
      UIEnhancements.init();
      Performance.init();

      console.log('✅ Website successfully initialized');

      // Add loaded class for CSS animations
      document.body.classList.add('js-loaded');

      // Analytics tracking (falls vorhanden)
      if (typeof gtag === 'function') {
        gtag('event', 'page_view', {
          page_title: document.title,
          page_location: window.location.href,
        });
      }
    } catch (error) {
      console.error('❌ Error initializing website:', error);

      // Fallback: Ensure basic functionality
      this.initFallbacks();
    }
  },

  initFallbacks() {
    console.log('Initializing fallback functionality...');

    // Basic smooth scroll fallback
    const navLinks = document.querySelectorAll('a[href^="#"]');
    navLinks.forEach(link => {
      link.addEventListener('click', e => {
        e.preventDefault();
        const target = document.querySelector(link.getAttribute('href'));
        if (target) {
          target.scrollIntoView({ behavior: 'smooth' });
        }
      });
    });

    // Basic form validation fallback
    const forms = document.querySelectorAll('form');
    forms.forEach(form => {
      form.addEventListener('submit', e => {
        const requiredFields = form.querySelectorAll('[required]');
        let isValid = true;

        requiredFields.forEach(field => {
          if (!field.value.trim()) {
            isValid = false;
            field.style.borderColor = '#dc3545';
          } else {
            field.style.borderColor = '';
          }
        });

        if (!isValid) {
          e.preventDefault();
          alert('Bitte füllen Sie alle erforderlichen Felder aus.');
        }
      });
    });
  },
};

// CSS Animation Classes (programmatisch hinzugefügt)
const CSS_ANIMATIONS = `
.animate-ready {
  opacity: 0;
  transform: translateY(30px);
  transition: all 0.6s ease-out;
}

.animate-in {
  opacity: 1;
  transform: translateY(0);
}

@keyframes bounce {
  0%, 20%, 53%, 80%, 100% {
    transform: translate3d(0,0,0);
  }
  40%, 43% {
    transform: translate3d(0, -10px, 0);
  }
  70% {
    transform: translate3d(0, -5px, 0);
  }
  90% {
    transform: translate3d(0, -2px, 0);
  }
}

.animate-bounce {
  animation: bounce 2s infinite;
}

.js-loaded .hero-content {
  animation: fadeInUp 1s ease-out;
}

@keyframes fadeInUp {
  from {
    opacity: 0;
    transform: translateY(50px);
  }
  to {
    opacity: 1;
    transform: translateY(0);
  }
}

.scroll-to-top {
  backdrop-filter: blur(10px);
  -webkit-backdrop-filter: blur(10px);
  background: rgba(37, 99, 235, 0.9) !important;
  border: none !important;
}

.scroll-to-top:hover {
  background: rgba(37, 99, 235, 1) !important;
  transform: translateY(-2px);
}

.skip-navigation {
  position: absolute;
  top: -40px;
  left: 6px;
  background: #000;
  color: #fff;
  padding: 8px;
  text-decoration: none;
  z-index: 100;
  border-radius: 4px;
}

.skip-navigation:focus {
  top: 6px;
  color: #fff;
}
`;

// CSS injection
const style = document.createElement('style');
style.textContent = CSS_ANIMATIONS;
document.head.appendChild(style);

// Start the application
App.init();

// Export für Debugging (development only)
if (window.location.hostname === 'localhost' || window.location.hostname === '127.0.0.1') {
  window.MenschlichkeitApp = {
    Navigation,
    ScrollAnimations,
    FormHandler,
    UIEnhancements,
    Performance,
    Utils,
    CONFIG,
  };
}
