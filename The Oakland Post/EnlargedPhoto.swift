//
//  EnlargedPhoto.swift
//  The Oakland Post
//
//  Created by Andrew Clissold on 7/23/14.
//  Copyright (c) 2014 Andrew Clissold. All rights reserved.
//


class EnlargedPhoto: UIView {

    let scrollView: UIScrollView
    let imageView: UIImageView

    init(image: UIImage!) {
        let window = UIApplication.sharedApplication().windows[0] as UIWindow

        imageView = UIImageView(image: image)
        scrollView = UIScrollView(frame: window.frame)

        imageView.backgroundColor = UIColor.blackColor()
        imageView.clipsToBounds = true
        imageView.contentMode = .ScaleAspectFit
        imageView.frame = window.frame
        imageView.userInteractionEnabled = true

        scrollView.contentSize = imageView.frame.size
        scrollView.maximumZoomScale = 2
        scrollView.minimumZoomScale = 1
        scrollView.addSubview(imageView)

        super.init(frame: window.frame)
        alpha = 0
        backgroundColor = UIColor.blackColor()
        addSubview(scrollView)
    }

}