//
//  ContentView.swift
//  UIViewRepresentableWithDynamicHeight_iOS_16
//
//  Created by FIX PRICE on 25/11/25.
//

import SwiftUI

fileprivate let animationDuration: CGFloat = 0.3

struct ContentView: View {
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            ForEach(0..<100, id: \.self) { _ in
                DynamicHeightView()
                    .background(.orange)
            }
        }
    }
}

#Preview {
    ContentView()
}

// если не поставить высоту (не важно внутри(sizeThatFits) или снаружи через модификатор) то занимает все доступное место
// если выстовлять frame у UIView то ничего не поменяется потому что SwiftUI.UIViewRepresentable берет на себя полный контроль над размером UIView
// если хочешь поменять высоту инкапсулированного InternalView то либо делай это снаружи через модификатор,
// либо используй UIViewRepresentable.sizeThatFits() на осях >= 16
// layout out внутри InternalView должне быть синхранизирован с высотой которая выстовляется через sizeThatFits

struct DynamicHeightView: UIViewRepresentable {
    @State private var height: CGFloat = 200
    
    func makeUIView(context: Context) -> InternalView {
        let view = InternalView()
        view.toggleAction = { isOn in
            withAnimation(.linear(duration: animationDuration)) {
                if isOn {
                    height = 300
                } else {
                    height = 200
                }
            }
        }
        return view
    }
    
    func updateUIView(_ uiView: InternalView, context: Context) {
        // do nothing
    }
    
    func sizeThatFits(
        _ proposal: ProposedViewSize,
        uiView: Self.UIViewType,
        context: Self.Context
    ) -> CGSize? {
        let intrinsicContentSize = uiView.intrinsicContentSize
        uiView.layer.cornerRadius = min(12, intrinsicContentSize.height / 2)
        return .some(.init(width: 200, height: height))
    }
}

extension DynamicHeightView {
    final class InternalView: UIView {
        private let shape = UIView()
        private let toggle = UISwitch()
        private var shapeHeightConstraint: NSLayoutConstraint?
        
        var toggleAction: ((Bool) -> Void)?
        
//        private var shapeInitialHeight: CGFloat = 100.0
//        override var intrinsicContentSize: CGSize {
//            let topOffset: CGFloat = 20
//            let shapeHeight = toggle.isOn ? shapeInitialHeight : 200
//            let toggleHeight = toggle.frame.height
//            let totalHeight = topOffset + shapeHeight + topOffset + toggleHeight + topOffset
//            
//            let horizontalOffset: CGFloat = 20
//            let shapeWidth = shape.frame.width
//            let toggleWidth = toggle.frame.width
//            let totalWidth = horizontalOffset + max(shapeWidth, toggleWidth) + horizontalOffset
//            
//            return .init(width: totalWidth, height: totalHeight)
//        }
        
        init() {
            super.init(frame: .zero)
            
            self.addSubview(shape)
            
            shape.backgroundColor = .blue
            
            shape.translatesAutoresizingMaskIntoConstraints = false
            shape.topAnchor.constraint(equalTo: self.topAnchor, constant: 20).isActive = true
            shape.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 20).isActive = true
            shape.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -20).isActive = true
            shape.widthAnchor.constraint(equalToConstant: 200).isActive = true
            shapeHeightConstraint = shape.heightAnchor.constraint(equalToConstant: 100)
            shapeHeightConstraint?.isActive = true
            
            self.addSubview(toggle)
            
            toggle.translatesAutoresizingMaskIntoConstraints = false
            toggle.topAnchor.constraint(equalTo: shape.bottomAnchor, constant: 20).isActive = true
            toggle.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
            
            toggle.addTarget(nil, action: #selector(didTapToggle), for: .valueChanged)
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        @objc private func didTapToggle() {
            UIView.animate(withDuration: animationDuration) {
                if self.toggle.isOn {
                    self.shapeHeightConstraint?.constant = 200
                } else {
                    self.shapeHeightConstraint?.constant = 100
                }
                
                self.layoutIfNeeded()
            }
            
            toggleAction?(toggle.isOn)
            toggle.setNeedsUpdateConstraints()
        }
    }
}
