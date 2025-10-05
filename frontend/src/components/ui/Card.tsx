import React from 'react';

export function Card({
  children,
  className = '',
}: {
  children?: React.ReactNode;
  className?: string;
}) {
  return (
    <div className={[
      'rounded-lg border border-semantic-border bg-white shadow-sm',
      className,
    ].join(' ')}>
      {children}
    </div>
  );
}
