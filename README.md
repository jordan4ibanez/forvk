# forvk
 You got Vulkan in my Fortran!

I have no idea what I'm doing.

![Womp womp womp womp](https://media.tenor.com/A_5FXBGEjkYAAAAM/yes.gif)

Something something deep quote about bringing the newest graphics api into the oldest language blah blah.

-----

## Note:

-----

So GCC Gfortran is stuck in 1993 and has a 63 character variable name limit.

I had to get creative to allow the Vulkan constants to be accessed in the same manor you can get them in the C docs.

-----



This program will probably blow up if you try to run it, but if you want to run it:

### Arch

```
yay -S vulkan-devel glfw shaderc
```

If you have an amd gpu:

```
yay -S vulkan-radeon
```

Probably missing something there.

Let me know if it blows up, thanks.

## Note:
MacOS will need MoltenVK. This is probably going to be a pain.