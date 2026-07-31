import React, { FormEvent, ReactElement, useCallback, useEffect, useState } from "react";
import style from './UserPage.less'
import useGetUser from "../../hooks/user/getUser";
import useSignIn from "../../hooks/user/signIn";
import useRegister from "../../hooks/user/register";


type AuthMode = "signIn" | "register";

interface AuthFormValues {
    username?: string;
    email: string;
    password: string;
    confirmPassword?: string;
    rememberMe?: boolean;
}

interface UserPageProps {
    setUserFn: any;
}


export function UserPage({setUserFn}:UserPageProps): ReactElement {
    const [activeMode, setActiveMode] =
        useState<AuthMode>("signIn");

    const getUserRequest = useGetUser();
    const signInRequest = useSignIn();
    const registerRequest = useRegister();

    const getUser = useCallback(async () => {
        const user = await getUserRequest();
        setUserFn({username: user.username, history: null});
        return user;
    }, [getUserRequest]);

    const signIn = useCallback(
        async (username: string, password: string) => {
            document.getElementById

            const { token } = await signInRequest(username, password);

            localStorage.setItem("token", token);

            return await getUser();
        },
        [signInRequest, getUser]
    );

    const register = useCallback(
        async (
            username: string,
            email: string,
            password: string
        ) => {
            const result = await registerRequest(
                username,
                email,
                password
            );

            if (result) {
                await getUser();
            }

            return result;
        },
        [registerRequest, getUser]
    );

    const isSignIn = activeMode === "signIn";

    function handleSubmit(
        event: FormEvent<HTMLFormElement>,
    ): void {
        event.preventDefault();

        const form = event.currentTarget;
        const formData = new FormData(form);

        const values: AuthFormValues = {
            username: formData.get("username")?.toString(),
            email:
                formData.get("email")?.toString() ?? "",
            password:
                formData.get("password")?.toString() ?? "",
            confirmPassword:
                formData
                    .get("confirmPassword")
                    ?.toString(),
            rememberMe:
                formData.get("rememberMe") === "on",
        };

        if (isSignIn && values.username && values.password) {
            signIn(values.username, values.password);
            return;
        }

        if (
            values.password !== values.confirmPassword
        ) {
            console.error("Passwords do not match");
            return;
        }

        if (!isSignIn && values.username && values.email && values.password) {
            register(values.username, values.email, values.password);
        }
            
    }

    function switchMode(): void {
        setActiveMode(
            isSignIn ? "register" : "signIn",
        );
    }

    useEffect(() => {
        getUser();
    }, [])

    return (
        <div className={style.userPage}>
            <section className={style.authWidget}>
                <div className={style.tabs}>
                    <button
                        type="button"
                        className={`${style.tab} ${
                            isSignIn
                                ? style.activeTab
                                : ""
                        }`}
                        onClick={() =>
                            setActiveMode("signIn")
                        }
                    >
                        Sign In
                    </button>

                    <button
                        type="button"
                        className={`${style.tab} ${
                            !isSignIn
                                ? style.activeTab
                                : ""
                        }`}
                        onClick={() =>
                            setActiveMode("register")
                        }
                    >
                        Register
                    </button>
                </div>

                <div className={style.content}>
                    <header className={style.heading}>
                        <div>
                            <h2>
                                {isSignIn
                                    ? "Welcome back"
                                    : "Create your account"}
                            </h2>

                            <p>
                                {isSignIn
                                    ? "Sign in to continue tracking your day."
                                    : "Start building a healthier daily routine."}
                            </p>
                        </div>
                    </header>

                    <form
                        className={style.form}
                        onSubmit={handleSubmit}
                    >
                        
                        <label
                            className={style.field}
                        >
                            <span>Username</span>

                            <input
                                type="text"
                                name="username"
                                placeholder="Your name"
                                autoComplete="username"
                                required
                            />
                        </label>
                        
                        
                        {!isSignIn && (
                            <label className={style.field}>
                                <span>Email</span>

                                <input
                                    type="email"
                                    name="email"
                                    placeholder="you@example.com"
                                    autoComplete="email"
                                    required
                                />
                            </label>
                        )}

                        <label className={style.field}>
                            <span>Password</span>

                            <input
                                type="password"
                                name="password"
                                placeholder="Enter your password"
                                autoComplete={
                                    isSignIn
                                        ? "current-password"
                                        : "new-password"
                                }
                                required
                            />
                        </label>

                        {!isSignIn && (
                            <label
                                className={style.field}
                            >
                                <span>
                                    Confirm password
                                </span>

                                <input
                                    type="password"
                                    name="confirmPassword"
                                    placeholder="Repeat your password"
                                    autoComplete="new-password"
                                    required
                                />
                            </label>
                        )}

                        {isSignIn && (
                            <div
                                className={style.options}
                            >
                                <label
                                    className={
                                        style.checkbox
                                    }
                                >
                                    <input
                                        type="checkbox"
                                        name="rememberMe"
                                    />

                                    <span>
                                        Remember me
                                    </span>
                                </label>

                                <button
                                    type="button"
                                    className={
                                        style.textButton
                                    }
                                >
                                    Forgot password?
                                </button>
                            </div>
                        )}

                        <button
                            type="submit"
                            className={
                                style.submitButton
                            }
                        >
                            {isSignIn
                                ? "Sign In"
                                : "Create Account"}
                        </button>
                    </form>

                    <p className={style.switchText}>
                        {isSignIn
                            ? "New to the app?"
                            : "Already have an account?"}

                        <button
                            type="button"
                            onClick={switchMode}
                        >
                            {isSignIn
                                ? "Register"
                                : "Sign in"}
                        </button>
                    </p>
                </div>
            </section>
        </div>
    );
}
