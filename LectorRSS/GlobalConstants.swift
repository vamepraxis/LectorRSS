//
//  GlobalConstants.swift
//  LectorRSS
//
//  Created by MacBook Pro on 19/10/18.
//  Copyright © 2018 ccc. All rights reserved.
//

import Foundation
import UIKit

//MARK: - User Defaults
public let prefs:UserDefaults = UserDefaults.standard

//MARK: - Device
public let device = UIDevice.current.model

//MARK: - Screen width
public let widthScreen = UIScreen.main.bounds.width

//MARK: - Screen height
public let heightScreen = UIScreen.main.bounds.height

//MARK: - Colors
public let colorPrimary: UIColor = UIColor(red:0/255, green: 133/255, blue: 119/255, alpha: 1)
public let colorPrimaryLight: UIColor = UIColor(red:30/255, green: 162/255, blue: 150/255, alpha: 1)

//MARK: - Loading view
public let container: UIView = UIView()
public let loadingView: UIView = UIView()
public let activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
public let  loadingLabel = UILabel()

public var refreshRSS = false
