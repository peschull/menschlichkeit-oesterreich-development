import React, { useState } from 'react';

type Props = React.ImgHTMLAttributes<HTMLImageElement> & {
  fallbackSrc?: string;
};

export const ImageWithFallback: React.FC<Props> = ({ fallbackSrc, onError, src, alt = '', ...rest }) => {
  const [error, setError] = useState(false);
  const handleError: React.ReactEventHandler<HTMLImageElement> = e => {
    setError(true);
    onError?.(e);
  };
  const effectiveSrc = !error ? src : fallbackSrc;
  return <img src={effectiveSrc} alt={alt} onError={handleError} {...rest} />;
};

export default ImageWithFallback;

