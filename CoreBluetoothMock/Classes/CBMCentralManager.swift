/*
* Copyright (c) 2020, Nordic Semiconductor
* All rights reserved.
*
* Redistribution and use in source and binary forms, with or without modification,
* are permitted provided that the following conditions are met:
*
* 1. Redistributions of source code must retain the above copyright notice, this
*    list of conditions and the following disclaimer.
*
* 2. Redistributions in binary form must reproduce the above copyright notice, this
*    list of conditions and the following disclaimer in the documentation and/or
*    other materials provided with the distribution.
*
* 3. Neither the name of the copyright holder nor the names of its contributors may
*    be used to endorse or promote products derived from this software without
*    specific prior written permission.
*
* THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
* ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
* WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
* IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT,
* INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT
* NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
* PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
* WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
* ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
* POSSIBILITY OF SUCH DAMAGE.
*/

import CoreBluetooth

public protocol CBMCentralManager: AnyObject {
    #if !os(macOS)
    @available(iOS 13.0, tvOS 13.0, watchOS 6.0, *)
    typealias Feature = CBCentralManager.Feature
    #endif
    
    /// The delegate object that will receive central events.
    var delegate: CBMCentralManagerDelegate? { get set }
    
    /// The current state of the manager, initially set to
    /// `CBManagerStateUnknown`. Updates are provided by required delegate
    /// method `centralManagerDidUpdateState(_:)`.
    var state: CBMManagerState { get }
    
    /// Whether or not the central is currently scanning.
    @available(iOS 9.0, *)
    var isScanning: Bool { get }
    
    #if !os(macOS)
    /// Returns a Boolean that indicates whether the device supports a
    /// specific set of features.
    /// - Parameter features: One or more features that you would like to
    ///                       check for support.
    @available(iOS 13.0, tvOS 13.0, watchOS 6.0, *)
    static func supports(_ features: CBMCentralManager.Feature) -> Bool
    #endif
    
    /// Scans for peripherals that are advertising services.
    ///
    /// You can provide an array of CBUUID objects — representing service
    /// UUIDs — in the serviceUUIDs parameter. When you do, the central
    /// manager returns only peripherals that advertise the services you
    /// specify. If the `serviceUUIDs` parameter is nil, this method returns
    /// all discovered peripherals, regardless of their supported services.
    ///
    /// - Note:
    /// The recommended practice is to populate the `serviceUUIDs`
    /// parameter rather than leaving it nil.
    ///
    /// If the central manager is actively scanning with one set of
    /// parameters and it receives another set to scan, the new parameters
    /// override the previous set. When the central manager discovers a
    /// peripheral, it calls the
    /// `centralManager(_:didDiscover:advertisementData:rssi:)` method of
    /// its delegate object.
    ///
    /// Your app can scan for Bluetooth devices in the background by
    /// specifying the bluetooth-central background mode. To do this, your
    /// app must explicitly scan for one or more services by specifying
    /// them in the `serviceUUIDs` parameter. The `CBMCentralManager` scan
    /// option has no effect while scanning in the background.
    /// - Parameters:
    ///   - serviceUUIDs: An array of `CBMUUID` objects that the app is
    ///                   interested in. Each `CBMUUID` object represents the
    ///                   UUID of a service that a peripheral advertises.
    ///   - options: A dictionary of options for customizing the scan. For
    ///              available options, see Peripheral Scanning Options.
    func scanForPeripherals(withServices serviceUUIDs: [CBMUUID]?, options: [String : Any]?)
    
    /// Asks the central manager to stop scanning for peripherals.
    func stopScan()
    
    /// Establishes a local connection to a peripheral.
    ///
    /// After successfully establishing a local connection to a peripheral,
    /// the central manager object calls the `centralManager(_:didConnect:)`
    /// method of its delegate object. If the connection attempt fails, the
    /// central manager object calls the
    /// `centralManager(_:didFailToConnect:error:)` method of its delegate
    /// object instead. Attempts to connect to a peripheral don’t time out.
    /// To explicitly cancel a pending connection to a peripheral, call the
    /// `cancelPeripheralConnection(_:)` method. Deallocating peripheral
    /// also implicitly calls `cancelPeripheralConnection(_:)`.
    /// - Parameters:
    ///   - peripheral: The peripheral to which the central is attempting
    ///                 to connect.
    ///   - options: A dictionary to customize the behavior of the
    ///              connection. For available options, see Peripheral
    ///              Connection Options.
    func connect(_ peripheral: CBMPeripheral, options: [String : Any]?)
    
    /// Cancels an active or pending local connection to a peripheral.
    ///
    /// This method is nonblocking, and any `CBMPeripheral` class commands
    /// that are still pending to peripheral may not complete. Because
    /// other apps may still have a connection to the peripheral, canceling
    /// a local connection doesn’t guarantee that the underlying physical
    /// link is immediately disconnected. From the app’s perspective,
    /// however, the peripheral is effectively disconnected, and the
    /// central manager object calls the
    /// `centralManager(_:didDisconnectPeripheral:error:)` method of its
    /// delegate object.
    /// - Parameter peripheral: The peripheral to which the central manager
    ///                         is either trying to connect or has already
    ///                         connected.
    func cancelPeripheralConnection(_ peripheral: CBMPeripheral)
    
    /// Returns a list of known peripherals by their identifiers.
    /// - Parameter identifiers: A list of peripheral identifiers
    ///                          (represented by NSUUID objects) from which
    ///                          `CBMPeripheral` objects can be retrieved.
    /// - Returns: A list of peripherals that the central manager is able
    ///            to match to the provided identifiers.
    @available(iOS 7.0, *)
    func retrievePeripherals(withIdentifiers identifiers: [UUID]) -> [CBMPeripheral]
    
    /// Returns a list of the peripherals connected to the system whose
    /// services match a given set of criteria.
    ///
    /// The list of connected peripherals can include those that other apps
    /// have connected. You need to connect these peripherals locally using
    /// the `connect(_:options:)` method before using them.
    /// - Parameter serviceUUIDs: A list of service UUIDs, represented by
    ///                           `CBMUUID` objects.
    /// - Returns: A list of the peripherals that are currently connected
    ///            to the system and that contain any of the services
    ///            specified in the `serviceUUID` parameter.
    @available(iOS 7.0, *)
    func retrieveConnectedPeripherals(withServices serviceUUIDs: [CBMUUID]) -> [CBMPeripheral]
    
    #if !os(macOS)
    /// Register for an event notification when the central manager makes a
    /// connection matching the given options.
    ///
    /// When the central manager makes a connection that matches the
    /// options, it calls the delegate’s
    /// `centralManager(_:connectionEventDidOccur:for:)` method.
    /// - Parameter options: A dictionary that specifies options for
    ///                      connection events. See Peripheral Connection
    ///                      Options for a list of possible options.
    @available(iOS 13.0, tvOS 13.0, watchOS 6.0, *)
    func registerForConnectionEvents(options: [CBMConnectionEventMatchingOption : Any]?)
    #endif
}

public extension CBMCentralManager {
    
    /// Scans for peripherals that are advertising services.
    ///
    /// You can provide an array of CBUUID objects — representing service
    /// UUIDs — in the serviceUUIDs parameter. When you do, the central
    /// manager returns only peripherals that advertise the services you
    /// specify. If the `serviceUUIDs` parameter is nil, this method returns
    /// all discovered peripherals, regardless of their supported services.
    ///
    /// - Note:
    /// The recommended practice is to populate the `serviceUUIDs`
    /// parameter rather than leaving it nil.
    ///
    /// If the central manager is actively scanning with one set of
    /// parameters and it receives another set to scan, the new parameters
    /// override the previous set. When the central manager discovers a
    /// peripheral, it calls the
    /// `centralManager(_:didDiscover:advertisementData:rssi:)` method of
    /// its delegate object.
    ///
    /// Your app can scan for Bluetooth devices in the background by
    /// specifying the bluetooth-central background mode. To do this, your
    /// app must explicitly scan for one or more services by specifying
    /// them in the `serviceUUIDs` parameter. The `CBMCentralManager` scan
    /// option has no effect while scanning in the background.
    /// - Parameters:
    ///   - serviceUUIDs: An array of `CBMUUID` objects that the app is
    ///                   interested in. Each `CBMUUID` object represents the
    ///                   UUID of a service that a peripheral advertises.
    func scanForPeripherals(withServices serviceUUIDs: [CBMUUID]?) {
        scanForPeripherals(withServices: serviceUUIDs, options: nil)
    }
    
    /// Establishes a local connection to a peripheral.
    ///
    /// After successfully establishing a local connection to a peripheral,
    /// the central manager object calls the `centralManager(_:didConnect:)`
    /// method of its delegate object. If the connection attempt fails, the
    /// central manager object calls the
    /// `centralManager(_:didFailToConnect:error:)` method of its delegate
    /// object instead. Attempts to connect to a peripheral don’t time out.
    /// To explicitly cancel a pending connection to a peripheral, call the
    /// `cancelPeripheralConnection(_:)` method. Deallocating peripheral
    /// also implicitly calls `cancelPeripheralConnection(_:)`.
    /// - Parameters:
    ///   - peripheral: The peripheral to which the central is attempting
    ///                 to connect.
    func connect(_ peripheral: CBMPeripheral) {
        connect(peripheral, options: nil)
    }
    
    #if !os(macOS)
    /// Register for an event notification when the central manager makes a
    /// connection matching the given options.
    ///
    /// When the central manager makes a connection that matches the
    /// options, it calls the delegate’s
    /// `centralManager(_:connectionEventDidOccur:for:)` method.
    @available(iOS 13.0, tvOS 13.0, watchOS 6.0, *)
    func registerForConnectionEvents() {
        registerForConnectionEvents(options: nil)
    }
    #endif
    
}
