export declare type AvatarItem =
    | { initials: string; avatarUrl?: never; useIcon?: never }
    | { initials?: never; avatarUrl: string; useIcon?: never }
    | { initials?: never; avatarUrl?: never; useIcon: boolean };
