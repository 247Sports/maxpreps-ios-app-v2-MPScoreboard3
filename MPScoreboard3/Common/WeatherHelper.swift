//
//  WeatherHelper.swift
//  MPScoreboard3
//
//  Created by David Smith on 10/5/22.
//

import UIKit

class WeatherHelper: NSObject
{
    // MARK: - Weather Images
    
    class func weatherImageFor(condition: Int, isDaylight: Bool) -> UIImage?
    {
        /*
                 0 Unknown - none
                 1 BlowingDust - Windy
                 2 Clear - Sunny or Moon
                 3 Cloudy - Cloudy or CloudyNight
                 4 Foggy - Foggy
                 5 Haze - Foggy
                 6 MostlyClear - CloudySun or CloudyNight
                 7 MostlyCloudy - Cloudy or CloudyNight
                 8 PartlyCloudy - CloudySun or CloudyNight
                 9 Smokey - Foggy
                 10 Breezy - Windy
                 11 Windy - Windy
                 12 Drizzle - CloudyRain
                 13 HeavyRain - CloudyRain
                 14 IsolatedThunderstorms - CloudyBolt
                 15 Rain - CloudyRain
                 16 SunShowers - CloudyRain
                 17 ScatteredThunderstorms - CloudyBolt
                 18 StrongStorms - CloudyRain
                 19 Thunderstorms - CloudyBolt
                 20 Frigid - Sunny or Moon
                 21 Hail - CloudyRain
                 22 Hot - Sunny or Moon
                 23 Flurries - Snow
                 24 Sleet - Snow
                 25 Snow - Snow
                 26 SunFlurries - Snow
                 27 WintryMix - Snow
                 28 Blizzard - Snow
                 29 BlowingSnow - Snow
                 30 FreezingDrizzle - CloudyRain
                 31 FreezingRain - CloudyRain
                 32 HeavySnow - Snow
                 33 Hurricane - Windy
                 34 TropicalStorm - Windy
         */
        switch condition
        {
        case 2, 20, 22:
            if (isDaylight == true)
            {
                return UIImage(named: "Sunny")
            }
            else
            {
                return UIImage(named: "Moon")
            }
        case 6, 8:
            if (isDaylight == true)
            {
                return UIImage(named: "CloudySun")
            }
            else
            {
                return UIImage(named: "CloudyNight")
            }
        case 3, 7:
            if (isDaylight == true)
            {
                return UIImage(named: "Cloudy")
            }
            else
            {
                return UIImage(named: "CloudyNight")
            }
        case 1, 10, 11, 33, 34:
                return UIImage(named: "Windy")
        case 12, 13, 15, 16, 18, 21, 30, 31:
                return UIImage(named: "CloudyRain")
        case 14, 17, 19:
                return UIImage(named: "CloudyBolt")
        case 23, 24, 25, 26, 27, 28, 29, 32:
                return UIImage(named: "Snow")
        case 4, 5, 9:
                return UIImage(named: "Foggy")
        default:
            return nil
        }
    }
}
