package com.example.auto_mobile_software

import android.Manifest
import android.bluetooth.BluetoothAdapter
import android.bluetooth.BluetoothClass
import android.bluetooth.BluetoothDevice
import android.content.pm.PackageManager
import android.os.Build
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.android.FlutterActivity
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val channelName = "zolana/printers"
    private val bluetoothConnectRequest = 4207
    private var pendingResult: MethodChannel.Result? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channelName)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "pairedBluetoothDevices" -> handlePairedBluetoothDevices(result)
                    else -> result.notImplemented()
                }
            }
    }

    private fun handlePairedBluetoothDevices(result: MethodChannel.Result) {
        if (!hasBluetoothConnectPermission()) {
            pendingResult = result
            requestPermissions(
                arrayOf(Manifest.permission.BLUETOOTH_CONNECT),
                bluetoothConnectRequest,
            )
            return
        }
        resolveBondedDevices(result)
    }

    private fun hasBluetoothConnectPermission(): Boolean {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.S) return true
        return checkSelfPermission(Manifest.permission.BLUETOOTH_CONNECT) ==
            PackageManager.PERMISSION_GRANTED
    }

    private fun resolveBondedDevices(result: MethodChannel.Result) {
        try {
            result.success(readBondedDevices())
        } catch (error: IllegalStateException) {
            result.error("bluetooth_unavailable", error.message, null)
        } catch (error: SecurityException) {
            result.error(
                "bluetooth_permission_denied",
                "Autorisez l'accès Bluetooth pour détecter l'imprimante.",
                null,
            )
        }
    }

    private fun readBondedDevices(): List<Map<String, Any?>> {
        val adapter = BluetoothAdapter.getDefaultAdapter()
            ?: throw IllegalStateException("Bluetooth non disponible sur ce device.")

        if (!adapter.isEnabled) {
            throw IllegalStateException("Activez le Bluetooth du device pour détecter l'imprimante.")
        }

        return adapter.bondedDevices.map { device ->
            mapOf(
                "name" to (device.name ?: "Appareil Bluetooth"),
                "address" to device.address,
                "isLikelyPrinter" to isLikelyPrinter(device),
                "isConnected" to isConnected(device),
            )
        }
    }

    private fun isLikelyPrinter(device: BluetoothDevice): Boolean {
        val name = device.name?.lowercase().orEmpty()
        if (
            name.contains("printer") ||
            name.contains("print") ||
            name.contains("pos") ||
            name.contains("thermal") ||
            name.contains("receipt") ||
            name.contains("imprimante")
        ) {
            return true
        }

        val major = device.bluetoothClass?.majorDeviceClass
        val deviceClass = device.bluetoothClass?.deviceClass
        return major == BluetoothClass.Device.Major.IMAGING ||
            deviceClass == BluetoothClass.Device.Major.IMAGING
    }

    private fun isConnected(device: BluetoothDevice): Boolean {
        return try {
            val method = device.javaClass.getMethod("isConnected")
            method.invoke(device) as? Boolean ?: false
        } catch (_: Exception) {
            false
        }
    }

    override fun onRequestPermissionsResult(
        requestCode: Int,
        permissions: Array<out String>,
        grantResults: IntArray,
    ) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults)
        if (requestCode != bluetoothConnectRequest) return

        val result = pendingResult ?: return
        pendingResult = null

        if (grantResults.firstOrNull() == PackageManager.PERMISSION_GRANTED) {
            resolveBondedDevices(result)
        } else {
            result.error(
                "bluetooth_permission_denied",
                "Autorisez l'accès Bluetooth pour détecter l'imprimante.",
                null,
            )
        }
    }
}
