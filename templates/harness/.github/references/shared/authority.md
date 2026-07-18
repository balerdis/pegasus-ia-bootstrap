# Pegasus Reference Authority

## Scope And Authority

This manually loaded reference owns instruction precedence and conflict handling only. It does not define phase workflow, persistence, status, delegation, skills, or result fields.

Precedence is: current macro > phase reference > shared reference > workspace default > global fallback. Lower levels cannot weaken higher safety gates. A same-level conflict blocks before writing.

Apply the narrowest authoritative contract for a concern. When contracts at different levels overlap, follow the higher level and report the overridden lower rule. When same-level contracts conflict, stop, identify both rules, and return a truthful blocked result.
