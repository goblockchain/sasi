"use strict";(self.webpackChunk_uniswap_interface=self.webpackChunk_uniswap_interface||[]).push([[2476],{17015:function(e,t,n){n.r(t),n.d(t,{default:function(){return $}});var i=n(42893),d=n(12204),r=n(19903),a=n(80815),o=n(66196),s=n(22875),c=n(6053),l=n(44998),p=n.n(l),u=n(13712),h=n(47212),m=n(41440),x=n(47096),f=n(87253),g=n(39839),j=n(60198),w=n(42246),v=n(60476),y=n(19969),A=n(16403),k=n(2304),b=n(20095),T=n(85729),C=n(91101),_=n(97761),R=n(42881),I=n(45433),B=n(57916),N=n(15387),F=n(30112),S=n(63362),D=n(61646),E=n(58025);const M=new I.vU(B.Mt),q={1:[{tokens:[E.Fl[N.ChainId.MAINNET],E.h1],stakingRewardAddress:"0xa1484C3aa22a66C62b77E0AE78E15258bd0cB711"},{tokens:[E.Fl[N.ChainId.MAINNET],E.Hz],stakingRewardAddress:"0x7FBa4B8Dc5E7616e59622806932DBea72537A56b"},{tokens:[E.Fl[N.ChainId.MAINNET],E.AA],stakingRewardAddress:"0x6C3e4cb2E96B01F4b866965A91ed4437839A121a"},{tokens:[E.Fl[N.ChainId.MAINNET],E.ML],stakingRewardAddress:"0xCA35e32e7926b96A9988f61d510E038108d8068e"}]};var W=n(64614);const P=(0,f.default)(v.Tz).withConfig({displayName:"v2__PageWrapper",componentId:"sc-fba52b73-0"})`
  max-width: 640px;
  width: 100%;

  ${({theme:e})=>e.deprecated_mediaWidth.deprecated_upToSmall`
    padding: 0px 8px;
  `};
`,z=(0,f.default)(y.I8).withConfig({displayName:"v2__LPFeeExplainer",componentId:"sc-fba52b73-1"})`
  background: radial-gradient(76.02% 75.41% at 1.84% 0%, #27ae60 0%, #000000 100%);
  margin: 0 0 16px 0;
  overflow: hidden;
`,L=(0,f.default)(k.m0).withConfig({displayName:"v2__TitleRow",componentId:"sc-fba52b73-2"})`
  ${({theme:e})=>e.deprecated_mediaWidth.deprecated_upToSmall`
    flex-wrap: wrap;
    gap: 12px;
    width: 100%;
    flex-direction: column-reverse;
  `};
`,U=(0,f.default)(k.DA).withConfig({displayName:"v2__ButtonRow",componentId:"sc-fba52b73-3"})`
  gap: 8px;
  ${({theme:e})=>e.deprecated_mediaWidth.deprecated_upToSmall`
    width: 100%;
    flex-direction: row-reverse;
    justify-content: space-between;
  `};
`,Y=(0,f.default)(j.DF).withConfig({displayName:"v2__ResponsiveButtonPrimary",componentId:"sc-fba52b73-4"})`
  height: 40px;
  width: fit-content;
  border-radius: 12px;
  ${({theme:e})=>e.deprecated_mediaWidth.deprecated_upToSmall`
    width: 48%;
  `};
`,H=(0,f.default)(j.PL).withConfig({displayName:"v2__ResponsiveButtonSecondary",componentId:"sc-fba52b73-5"})`
  height: 40px;
  width: fit-content;
  ${({theme:e})=>e.deprecated_mediaWidth.deprecated_upToSmall`
    width: 48%;
  `};
`,O=f.default.div.withConfig({displayName:"v2__EmptyProposals",componentId:"sc-fba52b73-6"})`
  border: 1px solid ${({theme:e})=>e.neutral2};
  padding: 16px 12px;
  border-radius: 12px;
  display: flex;
  flex-direction: column;
  justify-content: center;
  align-items: center;
`;function $(){const e=(0,f.useTheme)(),{account:t}=(0,a.useWeb3React)(),n=(0,c.G)();let l=(0,W.B3)();n||(l=[]);const I=(0,u.useMemo)((()=>l.map((e=>({liquidityToken:(0,W.Ce)(e),tokens:e})))),[l]),B=(0,u.useMemo)((()=>I.map((e=>e.liquidityToken))),[I]),[$,Z]=(0,R.v2)(t??void 0,B),G=(0,u.useMemo)((()=>I.filter((({liquidityToken:e})=>$[e.address]?.greaterThan("0")))),[I,$]),J=(0,_.OY)(G.map((({tokens:e})=>e))),V=Z||J?.length<G.length||J?.some((e=>!e)),Q=J.map((([,e])=>e)).filter((e=>Boolean(e))),X=function(e){const{chainId:t,account:n}=(0,a.useWeb3React)(),i=(0,S.Z)(),d=(0,u.useMemo)((()=>t?q[t]?.filter((t=>void 0===e||null!==e&&e.involvesToken(t.tokens[0])&&e.involvesToken(t.tokens[1])))??[]:[]),[t,e]),r=t?E.yg[t]:void 0,o=(0,u.useMemo)((()=>d.map((({stakingRewardAddress:e})=>e))),[d]),s=(0,u.useMemo)((()=>[n??void 0]),[n]),c=(0,D._Y)(o,M,"balanceOf",s),l=(0,D._Y)(o,M,"earned",s),h=(0,D._Y)(o,M,"totalSupply"),m=(0,D._Y)(o,M,"rewardRate",void 0,D.DB),x=(0,D._Y)(o,M,"periodFinish",void 0,D.DB);return(0,u.useMemo)((()=>t&&r?o.reduce(((e,t,n)=>{const a=c[n],o=l[n],s=h[n],u=m[n],f=x[n];if(!a?.loading&&!o?.loading&&s&&!s.loading&&u&&!u.loading&&f&&!f.loading){if(a?.error||o?.error||s.error||u.error||f.error)return console.error("Failed to load staking rewards info"),e;const c=d[n].tokens,l=new F.Pair(N.CurrencyAmount.fromRawAmount(c[0],"0"),N.CurrencyAmount.fromRawAmount(c[1],"0")),h=N.CurrencyAmount.fromRawAmount(l.liquidityToken,p().BigInt(a?.result?.[0]??0)),m=N.CurrencyAmount.fromRawAmount(l.liquidityToken,p().BigInt(s.result?.[0])),x=N.CurrencyAmount.fromRawAmount(r,p().BigInt(u.result?.[0])),g=(e,t,n)=>N.CurrencyAmount.fromRawAmount(r,p().greaterThan(t.quotient,p().BigInt(0))?p().divide(p().multiply(n.quotient,e.quotient),t.quotient):p().BigInt(0)),j=g(h,m,x),w=f.result?.[0]?.toNumber(),v=1e3*w,y=!w||!i||w>i.toNumber();e.push({stakingRewardAddress:t,tokens:d[n].tokens,periodFinish:v>0?new Date(v):void 0,earnedAmount:N.CurrencyAmount.fromRawAmount(r,p().BigInt(o?.result?.[0]??0)),rewardRate:j,totalRewardRate:x,stakedAmount:h,totalStakedAmount:m,getHypotheticalRewardRate:g,active:y})}return e}),[]):[]),[c,t,i,l,d,x,m,o,h,r])}(),K=X?.filter((e=>p().greaterThan(e.stakedAmount.quotient,C.iV))),ee=(0,_.OY)(K?.map((e=>e.tokens))),te=Q.filter((e=>0===ee?.map((e=>e[1])).filter((t=>t?.liquidityToken.address===e.liquidityToken.address)).length));return(0,i.jsx)(o.fM,{page:r.yJ.POOL_PAGE,shouldLogImpression:!0,children:(0,i.jsxs)(i.Fragment,{children:[(0,i.jsxs)(P,{children:[(0,i.jsxs)(z,{children:[(0,i.jsx)(y.sq,{}),(0,i.jsx)(y.RF,{}),(0,i.jsx)(y.uO,{children:(0,i.jsxs)(v.Tz,{gap:"md",children:[(0,i.jsx)(k.m0,{children:(0,i.jsx)(g.Tv.DeprecatedWhite,{fontWeight:535,children:(0,i.jsx)(d.cC,{id:"Vsr1yC"})})}),(0,i.jsx)(k.m0,{children:(0,i.jsx)(g.Tv.DeprecatedWhite,{fontSize:14,children:(0,i.jsx)(d.cC,{id:"vRS32S"})})}),(0,i.jsx)(g.dL,{style:{color:e.white,textDecoration:"underline"},target:"_blank",href:"https://docs.uniswap.org/contracts/v2/concepts/core-concepts/pools",children:(0,i.jsx)(g.Tv.DeprecatedWhite,{fontSize:14,children:(0,i.jsx)(d.cC,{id:"7bNFf2"})})})]})}),(0,i.jsx)(y.sq,{}),(0,i.jsx)(y.RF,{})]}),n?(0,i.jsx)(v.Tz,{gap:"lg",justify:"center",children:(0,i.jsxs)(v.Tz,{gap:"md",style:{width:"100%"},children:[(0,i.jsxs)(L,{style:{marginTop:"1rem"},padding:"0",children:[(0,i.jsx)(g.Pw,{children:(0,i.jsx)(g.Tv.DeprecatedMediumHeader,{style:{marginTop:"0.5rem",justifySelf:"flex-start"},children:(0,i.jsx)(d.cC,{id:"MbHgIE"})})}),(0,i.jsxs)(U,{children:[(0,i.jsx)(H,{as:m.rU,padding:"6px 8px",to:"/add/v2/ETH",children:(0,i.jsx)(d.cC,{id:"ma87bD"})}),(0,i.jsx)(Y,{id:"find-pool-button",as:m.rU,to:"/pools/v2/find",padding:"6px 8px",children:(0,i.jsx)(x.xv,{fontWeight:535,fontSize:16,children:(0,i.jsx)(d.cC,{id:"SkceS7"})})}),(0,i.jsx)(Y,{id:"join-pool-button",as:m.rU,to:"/add/v2/ETH",padding:"6px 8px",children:(0,i.jsx)(x.xv,{fontWeight:535,fontSize:16,children:(0,i.jsx)(d.cC,{id:"knGjuL"})})})]})]}),t?V?(0,i.jsx)(O,{children:(0,i.jsx)(g.Tv.DeprecatedBody,{color:e.neutral3,textAlign:"center",children:(0,i.jsx)(b.bb,{children:(0,i.jsx)(d.cC,{id:"yQE2r9"})})})}):Q?.length>0||ee?.length>0?(0,i.jsxs)(i.Fragment,{children:[(0,i.jsx)(j.PL,{children:(0,i.jsx)(k.m0,{children:(0,i.jsx)(d.cC,{id:"vAuUUB",components:{0:(0,i.jsx)(g.dL,{href:"https://v2.info.uniswap.org/account/"+t}),1:(0,i.jsx)("span",{})}})})}),te.map((e=>(0,i.jsx)(A.ZP,{pair:e},e.liquidityToken.address))),ee.map(((e,t)=>e[1]&&(0,i.jsx)(A.ZP,{pair:e[1],stakedBalance:K[t].stakedAmount},K[t].stakingRewardAddress))),(0,i.jsx)(k.DA,{justify:"center",style:{width:"100%"},children:(0,i.jsxs)(j.JU,{as:m.rU,to:"/migrate/v2",id:"import-pool-link",style:{padding:"8px 16px",margin:"0 4px",borderRadius:"12px",width:"fit-content",fontSize:"14px"},children:[(0,i.jsx)(h.Z,{size:16,style:{marginRight:"8px"}}),(0,i.jsx)(d.cC,{id:"kBAezW"})]})})]}):(0,i.jsx)(O,{children:(0,i.jsx)(g.Tv.DeprecatedBody,{color:e.neutral3,textAlign:"center",children:(0,i.jsx)(d.cC,{id:"erwMRf"})})}):(0,i.jsx)(w.ZP,{padding:"40px",children:(0,i.jsx)(g.Tv.DeprecatedBody,{color:e.neutral3,textAlign:"center",children:(0,i.jsx)(d.cC,{id:"jWRT4F"})})})]})}):(0,i.jsx)(s.A,{})]}),(0,i.jsx)(T.c,{})]})})}},49111:function(e,t,n){n.d(t,{B:function(){return r}});var i=n(48141),d=n(58025);function r(e){if(e.isNative)return e;const t=(0,i.oG)(e.chainId);return t&&d.Fl[t]?.equals(e)?(0,d.gX)(e.chainId):e}}}]);
//# sourceMappingURL=2476.09149211.chunk.js.map