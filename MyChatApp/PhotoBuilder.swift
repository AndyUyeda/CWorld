//
//  PhotoBuilder.swift
//  MyChatApp
//
//  Created by Rayan Slim on 2017-06-19.
//  Copyright © 2017 Rayan Slim. All rights reserved.
//

import Foundation
import Chatto
import ChattoAdditions



class PhotoViewModel: PhotoMessageViewModel<PhotoModel> {
    
    override init(photoMessage: PhotoModel, messageViewModel: MessageViewModelProtocol) {
        super.init(photoMessage: photoMessage, messageViewModel: messageViewModel)
    }
}




class PhotoBuilder: ViewModelBuilderProtocol {
    
    
    func canCreateViewModel(fromModel decoratedPhotoMessage: Any) -> Bool {
        return decoratedPhotoMessage is PhotoModel
    }
    
    func createViewModel(_ decoratedPhotoMessage: PhotoModel) -> PhotoViewModel {
        let PhotoMessageViewModel = PhotoViewModel(photoMessage: decoratedPhotoMessage, messageViewModel: MessageViewModelDefaultBuilder().createMessageViewModel(decoratedPhotoMessage))
        return PhotoMessageViewModel
    }
    
    
}
