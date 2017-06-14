// { "framework": "Vue" }

/******/ (function(modules) { // webpackBootstrap
/******/ 	// The module cache
/******/ 	var installedModules = {};

/******/ 	// The require function
/******/ 	function __webpack_require__(moduleId) {

/******/ 		// Check if module is in cache
/******/ 		if(installedModules[moduleId])
/******/ 			return installedModules[moduleId].exports;

/******/ 		// Create a new module (and put it into the cache)
/******/ 		var module = installedModules[moduleId] = {
/******/ 			exports: {},
/******/ 			id: moduleId,
/******/ 			loaded: false
/******/ 		};

/******/ 		// Execute the module function
/******/ 		modules[moduleId].call(module.exports, module, module.exports, __webpack_require__);

/******/ 		// Flag the module as loaded
/******/ 		module.loaded = true;

/******/ 		// Return the exports of the module
/******/ 		return module.exports;
/******/ 	}


/******/ 	// expose the modules object (__webpack_modules__)
/******/ 	__webpack_require__.m = modules;

/******/ 	// expose the module cache
/******/ 	__webpack_require__.c = installedModules;

/******/ 	// __webpack_public_path__
/******/ 	__webpack_require__.p = "";

/******/ 	// Load entry module and return exports
/******/ 	return __webpack_require__(0);
/******/ })
/************************************************************************/
/******/ ([
/* 0 */
/***/ (function(module, exports, __webpack_require__) {

	'use strict';

	Object.defineProperty(exports, "__esModule", {
	  value: true
	});

	var _foo = __webpack_require__(1);

	var _foo2 = _interopRequireDefault(_foo);

	function _interopRequireDefault(obj) { return obj && obj.__esModule ? obj : { default: obj }; }

	_foo2.default.el = '#root';
	exports.default = new Vue(_foo2.default);

/***/ }),
/* 1 */
/***/ (function(module, exports, __webpack_require__) {

	var __vue_exports__, __vue_options__
	var __vue_styles__ = []

	/* styles */
	__vue_styles__.push(__webpack_require__(2)
	)

	/* script */
	__vue_exports__ = __webpack_require__(3)

	/* template */
	var __vue_template__ = __webpack_require__(4)
	__vue_options__ = __vue_exports__ = __vue_exports__ || {}
	if (
	  typeof __vue_exports__.default === "object" ||
	  typeof __vue_exports__.default === "function"
	) {
	if (Object.keys(__vue_exports__).some(function (key) { return key !== "default" && key !== "__esModule" })) {console.error("named exports are not supported in *.vue files.")}
	__vue_options__ = __vue_exports__ = __vue_exports__.default
	}
	if (typeof __vue_options__ === "function") {
	  __vue_options__ = __vue_options__.options
	}
	__vue_options__.__file = "/Users/m/Documents/Weex/awesome-project/src/foo.vue"
	__vue_options__.render = __vue_template__.render
	__vue_options__.staticRenderFns = __vue_template__.staticRenderFns
	__vue_options__._scopeId = "data-v-54464a44"
	__vue_options__.style = __vue_options__.style || {}
	__vue_styles__.forEach(function (module) {
	  for (var name in module) {
	    __vue_options__.style[name] = module[name]
	  }
	})
	if (typeof __register_static_styles__ === "function") {
	  __register_static_styles__(__vue_options__._scopeId, __vue_styles__)
	}

	module.exports = __vue_exports__


/***/ }),
/* 2 */
/***/ (function(module, exports) {

	module.exports = {
	  "image": {
	    "width": 750,
	    "height": 422
	  },
	  "slider": {
	    "height": 422
	  },
	  "frame": {
	    "width": 750,
	    "height": 422,
	    "position": "relative"
	  },
	  "mask": {
	    "position": "absolute",
	    "bottom": 0,
	    "width": 750,
	    "height": 58,
	    "backgroundColor": "rgba(40,40,40,0.3)",
	    "boxSizing": "border-box",
	    "padding": 10,
	    "color": "#ffffff",
	    "fontSize": 30,
	    "overflow": "hidden"
	  },
	  "text": {
	    "width": 500,
	    "height": 38,
	    "lineHeight": 39,
	    "color": "#ffffff",
	    "fontSize": 34,
	    "display": "block",
	    "whiteSpace": "nowrap",
	    "textOverflow": "ellipsis"
	  },
	  "indicators": {
	    "width": 700,
	    "height": 700,
	    "itemColor": "#888888",
	    "itemSelectedColor": "#ffffff",
	    "itemSize": 24,
	    "position": "absolute",
	    "top": 44,
	    "left": 280
	  },
	  "list": {
	    "marginBottom": 3,
	    "position": "relative",
	    "width": 750,
	    "overflow": "hidden",
	    "borderBottomWidth": 2,
	    "borderBottomStyle": "solid",
	    "borderBottomColor": "#dfdfdd",
	    "paddingTop": 24,
	    "paddingRight": 16,
	    "paddingBottom": 24,
	    "paddingLeft": 16,
	    "boxSizing": "border-box",
	    "flexDirection": "row"
	  },
	  "images": {
	    "width": 300,
	    "height": 165,
	    "borderRadius": 10,
	    "flex": 1
	  },
	  "content": {
	    "width": 300,
	    "height": 165,
	    "left": 20,
	    "flex": 2
	  },
	  "catalogname": {
	    "display": "inline-block",
	    "fontSize": 24,
	    "position": "absolute",
	    "top": 128,
	    "color": "#808080"
	  },
	  "publishdate": {
	    "display": "inline-block",
	    "fontSize": 24,
	    "position": "absolute",
	    "top": 132,
	    "right": 16,
	    "color": "#808080"
	  },
	  "loading-view": {
	    "height": 80,
	    "width": 750,
	    "justifyContent": "center",
	    "alignItems": "center",
	    "backgroundColor": "#c0c0c0"
	  },
	  "indicator": {
	    "height": 40,
	    "width": 40,
	    "color": "#45b5f0"
	  }
	}

/***/ }),
/* 3 */
/***/ (function(module, exports) {

	'use strict';

	Object.defineProperty(exports, "__esModule", {
	  value: true
	});
	//
	//
	//
	//
	//
	//
	//
	//
	//
	//
	//
	//
	//
	//
	//
	//
	//
	//
	//
	//
	//
	//
	//
	//
	//
	//
	//
	//
	//
	//
	//
	//
	//
	//
	//
	//
	//
	//
	//
	//
	//
	//
	//
	//
	//
	//
	//
	//
	//
	//
	//
	//
	//
	//
	//
	//
	//
	//
	//
	//
	//
	//
	//
	//
	//
	//
	//
	//
	//
	//
	//
	//
	//
	//
	//
	//
	//
	//
	//
	//
	//
	//
	//
	//
	//
	//
	//
	//
	//
	//
	//
	//
	//
	//
	//
	//
	//
	//
	//
	//
	//
	//
	//
	//
	//
	//
	//
	//
	//
	//
	//
	//
	//
	//
	//
	//
	//
	//
	//
	//
	//
	//
	//
	//
	//
	//
	//
	//
	//
	//
	//
	//
	//
	//
	//
	//
	//
	//
	//
	//
	//
	//
	//
	//
	//
	//
	//

	var stream = weex.requireModule('stream');
	exports.default = {
	  data: function data() {
	    return {
	      count: 1,
	      loading_display: 'hide',
	      imageList: [{ src: 'https://cmsqn-test.infinitus.com.cn/upload/resources/image/2017/02/06/52232.jpg', text: '内部打开外链' }, { src: 'https://www-test.infinitus.com.cn/upload/resources/image/2017/02/17/52809.jpg', text: '【打开方式：外部】无限极网站。' }, { src: 'https://www-test.infinitus.com.cn/upload/resources/image/2017/01/05/51151.jpg', text: '【视频】中国智能手机用户分析' }, { src: 'https://cmsqn-test.infinitus.com.cn/upload/resources/image/2017/02/08/52242.jpg', text: '【内部栏目】公司新闻' }, { src: 'https://cmsqn-test.infinitus.com.cn/upload/resources/image/2017/02/08/52245.jpg', text: '【图】2016亲情之旅：在世上最幸福的国度，面朝大海心暖花开' }],
	      itemList: []
	    };
	  },

	  methods: {
	    onloading: function onloading() {
	      this.loading_display = 'show';
	      this.count += 1;
	      this.request();
	    },
	    request: function request() {
	      var self = this;
	      var params = encodeURIComponent(JSON.stringify({ navItemID: '170', pageIndex: +this.count, pageSize: '15' }));
	      stream.fetch({
	        method: 'GET',
	        url: 'https://www-test.infinitus.com.cn/front/api/json?username=invoke&password=abc123&method=CMSNavContentListData&params=' + params,
	        type: 'json'
	      }, function (response) {
	        if (response.status === 200) {
	          var moreList = response.data.Data;
	          var delay = self.itemList.length === 0 ? 0 : 1000;
	          setTimeout(function () {
	            for (var i = 0; i < moreList.length; i += 1) {
	              self.itemList.push(moreList[i]);
	            }
	            self.loading_display = 'hide';
	          }, delay);
	        } else {
	          console.log(222);
	        }
	      });
	    }
	  },
	  created: function created() {
	    this.request();
	  }
	};

/***/ }),
/* 4 */
/***/ (function(module, exports) {

	module.exports={render:function (){var _vm=this;var _h=_vm.$createElement;var _c=_vm._self._c||_h;
	  return _c('div', [_c('list', {
	    attrs: {
	      "showScrollbar": false
	    }
	  }, [_c('cell', {
	    staticClass: ["header"],
	    appendAsTree: true,
	    attrs: {
	      "append": "tree"
	    }
	  }, [_c('slider', {
	    staticClass: ["slider"],
	    attrs: {
	      "interval": "3000",
	      "autoPlay": "true"
	    }
	  }, [_vm._l((_vm.imageList), function(img) {
	    return _c('div', {
	      staticClass: ["frame"]
	    }, [_c('image', {
	      staticClass: ["image"],
	      attrs: {
	        "resize": "cover",
	        "src": img.src
	      }
	    }), _c('div', {
	      staticClass: ["mask"]
	    }, [_c('div', [_c('text', {
	      staticClass: ["text"],
	      attrs: {
	        "src": img.text
	      }
	    }, [_vm._v(_vm._s(img.text))])])])])
	  }), _c('indicator', {
	    staticClass: ["indicators"]
	  })], 2)]), _vm._l((_vm.itemList), function(item) {
	    return _c('cell', {
	      staticClass: ["list"],
	      appendAsTree: true,
	      attrs: {
	        "append": "tree"
	      }
	    }, [(item.LogoFile) ? _c('image', {
	      staticClass: ["images"],
	      attrs: {
	        "src": item.LogoFile
	      }
	    }) : _vm._e(), _c('div', {
	      staticClass: ["content"]
	    }, [(item.Title) ? _c('text', [_vm._v(_vm._s(item.Title))]) : _vm._e(), (item.CatalogName) ? _c('text', {
	      staticClass: ["catalogname"]
	    }, [_vm._v(_vm._s(item.CatalogName))]) : _vm._e(), (item.PublishDate) ? _c('text', {
	      staticClass: ["publishdate"]
	    }, [_vm._v(_vm._s(item.PublishDate.split(" ")[0]))]) : _vm._e()])])
	  }), _c('loading', {
	    staticClass: ["loading-view"],
	    attrs: {
	      "display": _vm.loading_display
	    },
	    on: {
	      "loading": _vm.onloading
	    }
	  }, [_c('loading-indicator', {
	    staticStyle: {
	      height: "60px",
	      width: "60px"
	    }
	  })], 1)], 2)])
	},staticRenderFns: []}
	module.exports.render._withStripped = true

/***/ })
/******/ ]);