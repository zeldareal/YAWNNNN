
### Not Nixvim Nvim

are on nixOS/using nix package manager, and want to use/are using nixvim? great!, head over to the main repo : https://github.com/zeldareal/YAWN
<br>
## installation
```bash
git clone https://github.com/zeldareal/peasant-YANC.git
cd peasant-YANC
chmod +x install.sh
./install.sh
```

** always check install scripts before running them!** ead through `install.sh` first to see what it does.
<br>
### First Launch

1. Open Neovim: `nvim`
2. Wait for lazy.nvim to install plugins (you'll see a window pop up)
   - **Expect errors during first install - this is completely normal!**
   - Don't panic when you see red text, just let it finish
3. Once installation completes, quit Neovim (`:q`)
4. Reopen Neovim: `nvim`
5. (Optional) Run `:Mason` to verify LSP servers are installing
6. (Optional) Run `:checkhealth` to diagnose any issues

thats it, should work

### troubleshooting

If you still see errors after reopening:
- Run `:Lazy sync` to update all plugins
- Run `:Mason` and press `U` to update all LSP servers
- Close and reopen Neovim one more time

If noice.nvim is acting weird:
```bash
rm -rf ~/.local/share/nvim/lazy
nvim  # let it reinstall everything
```
