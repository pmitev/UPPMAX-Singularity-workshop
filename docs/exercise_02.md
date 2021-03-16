# Build, sign, and upload Singularity container to Sylabs container library.

[Online material](https://sylabs.io/guides/3.7/user-guide/cloud_library.html)

## 1. Make an account
1. Go to: https://cloud.sylabs.io/library.
2. Click "Sign in to Sylabs" (top right corner).
3. Select your method to sign in, with Google, GitHub, GitLab, or Microsoft.
4. Type your passwords, and that's it!

## 2. Create an access token and login: [link](https://sylabs.io/guides/3.7/user-guide/cloud_library.html#creating-a-access-token)

## 3. Pushing container

```
$ singularity push my-container.sif library://your-name/project-dir/my-container:latest
```

!!! info
    - Use lower case for `project-dir` to avoid strange problems.
    - You might need to use `-U` or `--allow-unsigned` to push the container.

## 4. Sign your container (optional): [link](https://sylabs.io/guides/3.7/user-guide/signNverify.html)