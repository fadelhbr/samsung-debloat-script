# Samsung Debloat Tool

![Debloater Script](/img/terminal.png)

A simple yet powerful tool to remove unwanted pre-installed apps from your Samsung phone. Created by [github@fadel](https://github.com/fadel).
This works best on Samsung phones. While other Android devices may also support it, the performance might not be as smooth and could cause issues on some models.

## 📱 What is this?

This tool helps you remove bloatware (pre-installed apps) from your Android device without rooting. It uses Android Debug Bridge (ADB) to safely disable unwanted apps for any user on the device.

## ✨ Features

- ✅ Debloat your Samsung phone with one click
- ✅ Custom list of apps to remove
- ✅ Option to restore removed apps
- ✅ Works on multiple devices
- ✅ Supports Windows, Mac, and Linux
- ✅ No root required!

## 🛠️ Requirements

- **ADB** installed on your computer (installation methods vary by platform - follow the documentation) ([download here](https://developer.android.com/studio/releases/platform-tools))
- **USB Debugging** enabled on your Android device
- A **USB cable** to connect your device to your computer

## 📋 How to Use

### Step 1: Prepare Your Device

1. Enable **Developer options** on your Android device:
   - Go to **Settings** > **About Phone**
   - Tap **Build Number** 7 times until you see "You are now a developer!"

2. Enable **USB Debugging**:
   - Go to **Settings** > **Developer options**
   - Turn on **USB Debugging**

3. Connect your device to your computer via USB
   - When prompted on your device, allow USB debugging

### Step 2: Prepare the Debloat List

1. Use the included `list_app.txt` file (already defined, customize it if you want)
2. Add package names of apps you want to remove, one per line. Example:
```
com.samsung.android.app.mirrorlink
com.samsung.android.app.notes
com.samsung.android.app.reminder
```

### Step 3: Run the Debloat Script

#### For Windows:

1. Double-click the `debloat_windows.bat` file
2. If asked, allow the script to run with admin rights
3. Follow the on-screen instructions:
   - Select your device if multiple are connected
   - Type `y` to confirm and start the debloat process

#### For Mac/Linux:

1. Open Terminal in the folder containing the script
2. Make the script executable:
   ```
   chmod +x debloat_linux_mac.sh
   ```
3. Run the script:
   ```
   ./debloat_linux_mac.sh
   ```
4. Enter your password when prompted for sudo access
5. Follow the on-screen instructions

### Step 4: Restore Apps (If Needed)

If you want to restore the removed apps:

#### For Windows:

1. Double-click the `revert_windows.bat` file
2. Follow the same steps as the debloat process

#### For Mac/Linux:

1. Make the revert script executable:
   ```
   chmod +x revert_linux_mac.sh
   ```
2. Run the script:
   ```
   ./revert_linux_mac.sh
   ```

## 📝 Tips

- **Restart your device** after debloating for best results
- **Be careful** when removing system apps as it may affect device functionality
- **Keep a backup** of your original `list_app.txt` for future use

## 📷 Results

After running this tool, you'll have a cleaner Android experience with more storage space and potentially better battery life, as shown in the image below:

<img src="/img/result.jpg" alt="Debloat Results" width="250"/>

## 🔋 Recommended Apps

For even better performance:
- **Battery Guardian**: Helps conserve battery life on Samsung devices ([Download from APKMirror](https://www.apkmirror.com/apk/samsung-electronics-co-ltd/battery-guardian/))
- **Thermal Guardian**: Maintains safe device temperatures, keeps charging cooler, and prevents overheating during gaming ([Download from APKMirror](https://www.apkmirror.com/apk/samsung-electronics-co-ltd/samsung-thermal-guardian/))

## ⚠️ Warning

- This tool is safe when used correctly, but use at your own risk
- Works from One UI 1 to One UI 7 (already tested)
- Some system apps may be essential for your device to function properly
- If you experience issues after removing certain apps, use the revert script to restore them

## 🙏 Credits

- Created by [github@fadel](https://github.com/fadel)
- Based on ADB platform tools by Google

---

Happy Debloating! 🚀