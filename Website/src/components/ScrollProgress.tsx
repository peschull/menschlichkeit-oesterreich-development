import React, { useState, useEffect } from 'react';
import { motion, useScroll, useSpring } from 'motion/react';

interface ScrollProgressProps {
  color?: string;
  height?: number;
  position?: 'top' | 'bottom';
}

export function ScrollProgress({ 
  color = 'var(--brand-gradient)',
  height = 3,
  position = 'top'
}: ScrollProgressProps) {
  const { scrollYProgress } = useScroll();
  const scaleX = useSpring(scrollYProgress, {
    stiffness: 100,
    damping: 30,
    restDelta: 0.001
  });

  const positionClass = position === 'top' ? 'top-0' : 'bottom-0';

  return (
    <motion.div
      className={`scroll-progress fixed left-0 right-0 ${positionClass} z-50`}
      style={{
        height: `${height}px`,
        background: 'var(--muted)',
      }}
    >
      <motion.div
        className="scroll-progress-bar h-full"
        style={{
          scaleX,
          transformOrigin: '0%',
          background: color,
        }}
      />
    </motion.div>
  );
}

export default ScrollProgress;