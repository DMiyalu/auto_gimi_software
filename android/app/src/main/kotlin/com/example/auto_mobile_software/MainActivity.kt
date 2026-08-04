package com.example.auto_mobile_software

import android.Manifest
import android.bluetooth.BluetoothAdapter
import android.bluetooth.BluetoothClass
import android.bluetooth.BluetoothDevice
import android.bluetooth.le.ScanCallback
import android.bluetooth.le.ScanResult
import android.bluetooth.le.ScanSettings
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.content.pm.PackageManager
import android.provider.Settings
import android.os.Build
import android.os.Handler
import android.os.Looper
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.android.FlutterActivity
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val channelName = "zolana/printers"
    private val bluetoothPermissionRequest = 4207
    private var pendingResult: MethodChannel.Result? = null
    private var pendingScan = false

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channelName)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "pairedBluetoothDevices" -> handleBluetoothDevices(result, scan = false)
                    "scanBluetoothDevices" -> handleBluetoothDevices(result, scan = true)
                    "openBluetoothSettings" -> openBluetoothSettings(result)
                    else -> result.notImplemented()
                }
            }
    }

    private fun handleBluetoothDevices(result: MethodChannel.Result, scan: Boolean) {
        if (pendingResult != null) {
            result.error(
                "bluetooth_search_running",
                "Une recherche Bluetooth est déjà en cours.",
                null,
            )
            return
        }

        val missingPermissions = missingBluetoothPermissions(scan)
        if (missingPermissions.isNotEmpty()) {
            pendingResult = result
            pendingScan = scan
            requestPermissions(
                missingPermissions.toTypedArray(),
                bluetoothPermissionRequest,
            )
            return
        }
        if (scan) {
            resolveScannedDevices(result)
        } else {
            resolveBondedDevices(result)
        }
    }

    private fun openBluetoothSettings(result: MethodChannel.Result) {
        try {
            startActivity(Intent(Settings.ACTION_BLUETOOTH_SETTINGS))
            result.success(null)
        } catch (error: Exception) {
            result.error(
                "bluetooth_settings_unavailable",
                "Impossible d'ouvrir les paramètres Bluetooth sur ce device.",
                null,
            )
        }
    }

    private fun missingBluetoothPermissions(scan: Boolean): List<String> {
        val permissions = mutableListOf<String>()
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            permissions.add(Manifest.permission.BLUETOOTH_CONNECT)
            if (scan) permissions.add(Manifest.permission.BLUETOOTH_SCAN)
        } else if (scan) {
            permissions.add(Manifest.permission.ACCESS_FINE_LOCATION)
        }

        return permissions.filter {
            checkSelfPermission(it) != PackageManager.PERMISSION_GRANTED
        }
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

    private fun resolveScannedDevices(result: MethodChannel.Result) {
        try {
            scanDevices(result)
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
                "source" to "Appairée",
                "isLikelyPrinter" to isLikelyPrinter(device),
                "isConnected" to isConnected(device),
            )
        }
    }

    private fun scanDevices(result: MethodChannel.Result) {
        val adapter = BluetoothAdapter.getDefaultAdapter()
            ?: throw IllegalStateException("Bluetooth non disponible sur ce device.")

        if (!adapter.isEnabled) {
            throw IllegalStateException("Activez le Bluetooth du device pour détecter l'imprimante.")
        }

        val devices = linkedMapOf<String, Map<String, Any?>>()
        adapter.bondedDevices.forEach { devices[it.address] = deviceToMap(it, "Appairée") }

        var completed = false
        lateinit var receiver: BroadcastReceiver
        var bleCallback: ScanCallback? = null

        fun finish() {
            if (completed) return
            completed = true
            try {
                unregisterReceiver(receiver)
            } catch (_: Exception) {
            }
            try {
                if (adapter.isDiscovering) adapter.cancelDiscovery()
            } catch (_: SecurityException) {
            }
            try {
                bleCallback?.let { adapter.bluetoothLeScanner?.stopScan(it) }
            } catch (_: Exception) {
            }
            result.success(devices.values.toList())
        }

        receiver = object : BroadcastReceiver() {
            override fun onReceive(context: Context, intent: Intent) {
                when (intent.action) {
                    BluetoothDevice.ACTION_FOUND -> {
                        val device = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
                            intent.getParcelableExtra(
                                BluetoothDevice.EXTRA_DEVICE,
                                BluetoothDevice::class.java,
                            )
                        } else {
                            @Suppress("DEPRECATION")
                            intent.getParcelableExtra(BluetoothDevice.EXTRA_DEVICE)
                        }
                        if (device?.address != null) {
                            devices[device.address] = deviceToMap(device, "Bluetooth classique")
                        }
                    }
                    BluetoothAdapter.ACTION_DISCOVERY_FINISHED -> finish()
                }
            }
        }

        val filter = IntentFilter().apply {
            addAction(BluetoothDevice.ACTION_FOUND)
            addAction(BluetoothAdapter.ACTION_DISCOVERY_FINISHED)
        }
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            registerReceiver(receiver, filter, Context.RECEIVER_NOT_EXPORTED)
        } else {
            registerReceiver(receiver, filter)
        }

        if (adapter.isDiscovering) adapter.cancelDiscovery()
        val classicStarted = adapter.startDiscovery()
        val bleStarted = startBleScan(adapter, devices) { bleCallback = it }

        if (!classicStarted && !bleStarted) {
            finish()
            return
        }

        Handler(Looper.getMainLooper()).postDelayed({ finish() }, 12000)
    }

    private fun startBleScan(
        adapter: BluetoothAdapter,
        devices: MutableMap<String, Map<String, Any?>>,
        onCallback: (ScanCallback) -> Unit,
    ): Boolean {
        val scanner = adapter.bluetoothLeScanner ?: return false
        val callback = object : ScanCallback() {
            override fun onScanResult(callbackType: Int, result: ScanResult) {
                val device = result.device ?: return
                if (device.address != null) {
                    devices[device.address] = deviceToMap(device, "BLE")
                }
            }

            override fun onBatchScanResults(results: MutableList<ScanResult>) {
                results.forEach { scanResult ->
                    val device = scanResult.device ?: return@forEach
                    if (device.address != null) {
                        devices[device.address] = deviceToMap(device, "BLE")
                    }
                }
            }
        }

        return try {
            val settings = ScanSettings.Builder()
                .setScanMode(ScanSettings.SCAN_MODE_LOW_LATENCY)
                .build()
            scanner.startScan(null, settings, callback)
            onCallback(callback)
            true
        } catch (_: Exception) {
            false
        }
    }

    private fun deviceToMap(device: BluetoothDevice, source: String): Map<String, Any?> {
        return mapOf(
            "name" to (device.name ?: "Appareil Bluetooth"),
            "address" to device.address,
            "source" to source,
            "isLikelyPrinter" to isLikelyPrinter(device),
            "isConnected" to isConnected(device),
        )
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
        if (requestCode != bluetoothPermissionRequest) return

        val result = pendingResult ?: return
        val shouldScan = pendingScan
        pendingResult = null
        pendingScan = false

        if (grantResults.isNotEmpty() && grantResults.all { it == PackageManager.PERMISSION_GRANTED }) {
            if (shouldScan) {
                resolveScannedDevices(result)
            } else {
                resolveBondedDevices(result)
            }
        } else {
            result.error(
                "bluetooth_permission_denied",
                "Autorisez l'accès Bluetooth pour détecter l'imprimante.",
                null,
            )
        }
    }
}
