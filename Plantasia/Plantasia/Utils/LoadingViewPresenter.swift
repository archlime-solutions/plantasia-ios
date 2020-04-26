//
//  LoadingViewPresenter.swift
//  Plantasia
//
//  Created by bogdan razvan on 25/04/2020.
//  Copyright © 2020 archlime solutions. All rights reserved.
//

import NVActivityIndicatorView

protocol LoadingViewPresenter where Self: BaseViewController {
    func showLoadingView()
    func hideLoadingView()
}

extension LoadingViewPresenter {

    func showLoadingView() {
        LoadingView.showLoadingAnimation()
    }

    func hideLoadingView() {
        LoadingView.hideLoadingAnimation()
    }

}

private class LoadingView: UIView {

    static func showLoadingAnimation() {
        let activityIndicatorData = ActivityData(type: .ballBeat, color: UIColor.black, backgroundColor: .clear)
        NVActivityIndicatorPresenter.sharedInstance.startAnimating(activityIndicatorData, NVActivityIndicatorView.DEFAULT_FADE_IN_ANIMATION)
    }

    static func hideLoadingAnimation() {
        NVActivityIndicatorPresenter.sharedInstance.stopAnimating(NVActivityIndicatorView.DEFAULT_FADE_OUT_ANIMATION)
    }

}
