import React from 'react';
import { Button } from './Button';

// Minimal Usage Snippets for Figma Dev Mode / Code Connect
// - Zeigt Standard- und Varianten-Nutzung kompakt.

export function ExamplePrimary() {
  return <Button variant="primary">Primary</Button>;
}

export function ExampleSecondary() {
  return <Button variant="secondary">Secondary</Button>;
}

export function ExampleSizes() {
  return (
    <div className="flex gap-2">
      <Button size="sm">Small</Button>
      <Button size="md">Medium</Button>
      <Button size="lg">Large</Button>
    </div>
  );
}
