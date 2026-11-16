type MailtoLinkProps = {
  email: string;
  label?: string;
};

export function MailtoLink({ email, label }: MailtoLinkProps) {
  return (
    <a className="mailto-glow" href={`mailto:${email}`}>
      {label ?? email}
    </a>
  );
}
