/**
 * Main Theme JavaScript
 * Menschlichkeit Theme - Core functionality
 */

(function (Drupal, once) {
  'use strict';

  /**
   * Dark Mode Toggle Functionality
   */
  Drupal.behaviors.darkModeToggle = {
    attach: function (context) {
      const toggleButton = once('dark-mode-toggle', '#dark-mode-toggle', context);
      
      if (toggleButton.length === 0) return;

      const button = toggleButton[0];
      const prefersDark = window.matchMedia('(prefers-color-scheme: dark)');
      
      // Get saved preference or use system preference
      const savedTheme = localStorage.getItem('theme');
      const systemTheme = prefersDark.matches ? 'dark' : 'light';
      const currentTheme = savedTheme || systemTheme;

      // Apply initial theme
      document.documentElement.classList.toggle('dark', currentTheme === 'dark');
      updateToggleIcon(button, currentTheme);

      // Toggle event listener
      button.addEventListener('click', function() {
        const isDark = document.documentElement.classList.contains('dark');
        const newTheme = isDark ? 'light' : 'dark';
        
        document.documentElement.classList.toggle('dark', newTheme === 'dark');
        localStorage.setItem('theme', newTheme);
        updateToggleIcon(button, newTheme);
        
        // Dispatch custom event for other components
        window.dispatchEvent(new CustomEvent('themeChanged', { 
          detail: { theme: newTheme } 
        }));
      });

      // Listen for system theme changes
      prefersDark.addEventListener('change', function(e) {
        if (!localStorage.getItem('theme')) {
          const newTheme = e.matches ? 'dark' : 'light';
          document.documentElement.classList.toggle('dark', newTheme === 'dark');
          updateToggleIcon(button, newTheme);
        }
      });
    }
  };

  /**
   * Update toggle button icon
   */
  function updateToggleIcon(button, theme) {
    const icon = button.querySelector('.btn__icon');
    if (!icon) return;

    if (theme === 'dark') {
      // Sun icon for light mode toggle
      icon.innerHTML = '<path d="M12 1v2M12 21v2m9-10h2M1 12h2m15.5-6.5L17 7M7 17l-1.5 1.5m11-11L17 7m-10 10l-1.5 1.5M12 7a5 5 0 100 10 5 5 0 000-10z"/>';
      button.setAttribute('aria-label', Drupal.t('Switch to light mode'));
    } else {
      // Moon icon for dark mode toggle
      icon.innerHTML = '<path d="M21 12.79A9 9 0 1 1 11.21 3 7 7 0 0 0 21 12.79z"/>';
      button.setAttribute('aria-label', Drupal.t('Switch to dark mode'));
    }
  }

  /**
   * Smooth Scroll for Anchor Links
   */
  Drupal.behaviors.smoothScroll = {
    attach: function (context) {
      const anchorLinks = once('smooth-scroll', 'a[href^="#"]', context);
      
      anchorLinks.forEach(function(link) {
        link.addEventListener('click', function(e) {
          const targetId = this.getAttribute('href').substring(1);
          const targetElement = document.getElementById(targetId);
          
          if (targetElement) {
            e.preventDefault();
            
            const headerHeight = document.querySelector('.header')?.offsetHeight || 0;
            const navHeight = document.querySelector('.navigation--primary')?.offsetHeight || 0;
            const offset = headerHeight + navHeight + 20; // 20px extra padding
            
            const targetPosition = targetElement.offsetTop - offset;
            
            window.scrollTo({
              top: targetPosition,
              behavior: 'smooth'
            });
            
            // Update focus for accessibility
            targetElement.focus({ preventScroll: true });
          }
        });
      });
    }
  };

  /**
   * Progressive Enhancement for Forms
   */
  Drupal.behaviors.formEnhancements = {
    attach: function (context) {
      // Auto-expand textareas
      const textareas = once('auto-expand', 'textarea', context);
      
      textareas.forEach(function(textarea) {
        // Set initial height
        autoResize(textarea);
        
        textarea.addEventListener('input', function() {
          autoResize(this);
        });
      });

      // Add loading states to form buttons
      const forms = once('form-loading', 'form', context);
      
      forms.forEach(function(form) {
        form.addEventListener('submit', function() {
          const submitButtons = form.querySelectorAll('button[type="submit"], input[type="submit"]');
          submitButtons.forEach(function(button) {
            button.classList.add('btn--loading');
            button.disabled = true;
            
            // Add loading text if it's a button element
            if (button.tagName === 'BUTTON') {
              button.dataset.originalText = button.textContent;
              button.innerHTML = '<span class="btn__icon" aria-hidden="true">⟳</span> ' + 
                (button.dataset.loadingText || Drupal.t('Loading...'));
            }
          });
        });
      });
    }
  };

  /**
   * Auto-resize textarea function
   */
  function autoResize(textarea) {
    textarea.style.height = 'auto';
    textarea.style.height = textarea.scrollHeight + 'px';
  }

  /**
   * Intersection Observer for Animation Triggers
   */
  Drupal.behaviors.scrollAnimations = {
    attach: function (context) {
      if (!window.IntersectionObserver) return;

      const animatedElements = once('scroll-animate', '[data-animate]', context);
      
      if (animatedElements.length === 0) return;

      const observer = new IntersectionObserver(function(entries) {
        entries.forEach(function(entry) {
          if (entry.isIntersecting) {
            const element = entry.target;
            const animationType = element.dataset.animate;
            
            element.classList.add('animate-' + animationType);
            
            // Stop observing once animated
            observer.unobserve(element);
          }
        });
      }, {
        threshold: 0.1,
        rootMargin: '0px 0px -50px 0px'
      });

      animatedElements.forEach(function(element) {
        observer.observe(element);
      });
    }
  };

  /**
   * Keyboard Navigation Enhancement
   */
  Drupal.behaviors.keyboardNavigation = {
    attach: function (context) {
      // Escape key handling for modals/dropdowns
      document.addEventListener('keydown', function(e) {
        if (e.key === 'Escape') {
          // Close any open modals
          const openModals = document.querySelectorAll('[open][role="dialog"]');
          openModals.forEach(function(modal) {
            modal.close();
          });
          
          // Close any open dropdowns
          const openDropdowns = document.querySelectorAll('.dropdown--open');
          openDropdowns.forEach(function(dropdown) {
            dropdown.classList.remove('dropdown--open');
          });
        }
      });

      // Focus trap for modals
      const modals = once('focus-trap', '[role="dialog"]', context);
      
      modals.forEach(function(modal) {
        modal.addEventListener('keydown', function(e) {
          if (e.key === 'Tab') {
            trapFocus(e, modal);
          }
        });
      });
    }
  };

  /**
   * Focus trap helper function
   */
  function trapFocus(e, container) {
    const focusableElements = container.querySelectorAll(
      'button, [href], input, select, textarea, [tabindex]:not([tabindex="-1"])'
    );
    const firstElement = focusableElements[0];
    const lastElement = focusableElements[focusableElements.length - 1];

    if (e.shiftKey) {
      if (document.activeElement === firstElement) {
        e.preventDefault();
        lastElement.focus();
      }
    } else {
      if (document.activeElement === lastElement) {
        e.preventDefault();
        firstElement.focus();
      }
    }
  }

  /**
   * Lazy Loading for Images
   */
  Drupal.behaviors.lazyLoading = {
    attach: function (context) {
      if (!window.IntersectionObserver) return;

      const lazyImages = once('lazy-load', 'img[data-src]', context);
      
      if (lazyImages.length === 0) return;

      const imageObserver = new IntersectionObserver(function(entries) {
        entries.forEach(function(entry) {
          if (entry.isIntersecting) {
            const img = entry.target;
            img.src = img.dataset.src;
            img.classList.add('loaded');
            imageObserver.unobserve(img);
          }
        });
      });

      lazyImages.forEach(function(img) {
        imageObserver.observe(img);
      });
    }
  };

  /**
   * Performance Monitoring
   */
  Drupal.behaviors.performanceMonitoring = {
    attach: function (context, settings) {
      // Only run on document ready, not AJAX contexts
      if (context !== document) return;

      // Log Core Web Vitals if available
      if ('web-vitals' in window) {
        window.webVitals.getCLS(function(metric) {
          console.log('CLS:', metric.value);
        });
        
        window.webVitals.getFID(function(metric) {
          console.log('FID:', metric.value);
        });
        
        window.webVitals.getLCP(function(metric) {
          console.log('LCP:', metric.value);
        });
      }

      // Simple performance timing
      window.addEventListener('load', function() {
        setTimeout(function() {
          const perfData = performance.timing;
          const loadTime = perfData.loadEventEnd - perfData.navigationStart;
          console.log('Page load time:', loadTime + 'ms');
        }, 0);
      });
    }
  };

})(Drupal, once);