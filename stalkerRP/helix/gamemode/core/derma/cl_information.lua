
local PANEL = {}

local nameBackGround = Material( "materials/textures/char_name.png" )
local descriptionBackGround = Material( "materials/textures/char_description.png" )

local littleButtonBackgronud = Material( "materials/textures/char_fraction_money_little.png" )
local littleButtonTextBack = Material( "materials/textures/char_fraction_money.png" )

function PANEL:Init()
	local parent = self:GetParent()

	self:SetSize(parent:GetWide() * 0.6, parent:GetTall())
	self:Dock(RIGHT)
	self:DockMargin(0, ScrH() * 0.05, 0, 0)

	self.VBar:SetWide(0)

	-- entry setup
	local suppress = {}
	hook.Run("CanCreateCharacterInfo", suppress)

	if (!suppress.time) then
		local format = "%A, %B %d, %Y. %H:%M:%S"

		self.time = self:Add("DLabel")
		self.time:SetFont("ixMediumFont")
		self.time:SetTall(28)
		self.time:SetContentAlignment(5)
		self.time:Dock(TOP)
		self.time:SetTextColor(color_white)
		self.time:SetExpensiveShadow(1, Color(0, 0, 0, 150))
		self.time:DockMargin(0, 0, 0, 32)
		self.time:SetText(ix.date.GetFormatted(format))
		self.time.Think = function(this)
			if ((this.nextTime or 0) < CurTime()) then
				this:SetText(ix.date.GetFormatted(format))
				this.nextTime = CurTime() + 0.5
			end
		end
	end

	if (!suppress.name) then
		-- container panel so we can center the label horizontally without colouring the entire background
		local namePanel = self:Add("Panel")
		namePanel:Dock(TOP)
		namePanel:DockMargin(0, 0, 0, 8)
		namePanel.PerformLayout = function(_, width, height)
			self.name:SetPos(width * 0.5 - self.name:GetWide() * 0.5, height * 0.5 - self.name:GetTall() * 0.5)
		end

		self.name = namePanel:Add("DLabel")
		self.name.backgroundColor = Color(0, 0, 0, 150)
		self.name:SetFont("StalkerFontLarge")
		self.name:SetContentAlignment(5)
		self.name:SetTextColor(color_white)
		self.name.Paint = function(this, width, height)
			surface.SetDrawColor( 255, 255, 255, 255 )
			surface.SetMaterial( nameBackGround )
			surface.DrawTexturedRect( -2, 0, width + 4, height )				
		end

		self.name.SizeToContents = function(this)
			local width, height = this:GetContentSize()
			width = width + 16
			height = height + 16

			this:SetSize(width, height)
			namePanel:SetTall(height)
		end
	end

	if (!suppress.description) then
		local descriptionPanel = self:Add("Panel")
		descriptionPanel:Dock(TOP)
		descriptionPanel:DockMargin(0, 0, 0, 8)
		descriptionPanel.PerformLayout = function(_, width, height)
			if (!self.description.bWrap) then
				self.description:SetPos(width * 0.5 - self.description:GetWide() * 0.5, height * 0.5 - self.description:GetTall() * 0.5)
			end
		end

		self.description = descriptionPanel:Add("DLabel")
		self.description:SetFont("StalkerGraffitiFont")
		self.description:SetTextColor(color_white)
		self.description:SetContentAlignment(5)
		self.description:SetMouseInputEnabled(true)
		self.description:SetCursor("hand")

		self.description.Paint = function(this, width, height)
			surface.SetDrawColor( 255, 255, 255, 255 )
			surface.SetMaterial( descriptionBackGround )
			surface.DrawTexturedRect( -6, -4, width+14, height )	
		end

		self.description.OnMousePressed = function(this, code)
			if (code == MOUSE_LEFT) then
				ix.command.Send("CharDesc")

				if (IsValid(ix.gui.menu)) then
					ix.gui.menu:Remove()
				end
			end
		end

		self.description.SizeToContents = function(this)
			if (this.bWrap) then
				-- sizing contents after initial wrapping does weird things so we'll just ignore (lol)
				return
			end

			local width, height = this:GetContentSize()

			if (width > self:GetWide()) then
				this:SetWide(self:GetWide())
				this:SetTextInset(16, 8)
				this:SetWrap(true)
				this:SizeToContentsY()
				this:SetTall(this:GetTall() + 16) -- eh

				-- wrapping doesn't like middle alignment so we'll do top-center
				self.description:SetContentAlignment(8)
				this.bWrap = true
			else
				this:SetSize(width + 16, height + 16)
			end

			descriptionPanel:SetTall(this:GetTall())
		end
	end

	if (!suppress.characterInfo) then
		self.characterInfo = self:Add("Panel")
		self.characterInfo.list = {}
		self.characterInfo:Dock(TOP) -- no dock margin because this is handled by ixListRow
		self.characterInfo.SizeToContents = function(this)
			local height = 0

			for _, v in ipairs(this:GetChildren()) do
				if (IsValid(v) and v:IsVisible()) then
					local _, top, _, bottom = v:GetDockMargin()
					height = height + v:GetTall() + top + bottom
				end
			end

			this:SetTall(height)
		end

		if (!suppress.faction) then
			self.faction = self.characterInfo:Add("ixListRow")
			self.faction:SetList(self.characterInfo.list)
			self.faction:Dock(TOP)
			self.faction.label:SetFont("StalkerGraffitiFont")
			self.faction.text:SetFont("StalkerGraffitiFont")
			self.faction.label.Paint = function(s, w, h)
				surface.SetDrawColor( 255, 255, 255, 255 )
				surface.SetMaterial( littleButtonBackgronud )
				surface.DrawTexturedRect( 0, 0, w, h )
			end;
			self.faction.text.Paint = function(s, w, h)
				surface.SetDrawColor( 255, 255, 255, 255 )
				surface.SetMaterial( littleButtonTextBack )
				surface.DrawTexturedRect( 0, 0, w, h )
			end;
		end

		if (!suppress.class) then
			self.class = self.characterInfo:Add("ixListRow")
			self.class:SetList(self.characterInfo.list)
			self.class:Dock(TOP)
			self.class.label:SetFont("StalkerGraffitiFont")
			self.class.text:SetFont("StalkerGraffitiFont")
			self.class.label.Paint = function(s, w, h)
				surface.SetDrawColor( 255, 255, 255, 255 )
				surface.SetMaterial( littleButtonBackgronud )
				surface.DrawTexturedRect( 0, 0, w, h )
			end;
			self.class.text.Paint = function(s, w, h)
				surface.SetDrawColor( 255, 255, 255, 255 )
				surface.SetMaterial( littleButtonTextBack )
				surface.DrawTexturedRect( 0, 0, w, h )
			end;
		end

		if (!suppress.money) then
			self.money = self.characterInfo:Add("ixListRow")
			self.money:SetList(self.characterInfo.list)
			self.money:Dock(TOP)
			self.money:SizeToContents()
			self.money.label:SetFont("StalkerGraffitiFont")
			self.money.text:SetFont("StalkerGraffitiFont")
			self.money.label.Paint = function(s, w, h)
				surface.SetDrawColor( 255, 255, 255, 255 )
				surface.SetMaterial( littleButtonBackgronud )
				surface.DrawTexturedRect( 0, 0, w, h )
			end;
			self.money.text.Paint = function(s, w, h)
				surface.SetDrawColor( 255, 255, 255, 255 )
				surface.SetMaterial( littleButtonTextBack )
				surface.DrawTexturedRect( 0, 0, w, h )
			end;
		end

		hook.Run("CreateCharacterInfo", self.characterInfo)
		self.characterInfo:SizeToContents()
	end

	-- no need to update since we aren't showing the attributes panel
	if (!suppress.attributes) then
		local character = LocalPlayer().GetCharacter and LocalPlayer():GetCharacter()

		if (character) then
			self.attributes = self:Add("ixCategoryPanel")
			self.attributes:SetText(L("attributes"))
			self.attributes:Dock(TOP)
			self.attributes:DockMargin(0, 0, 0, 8)

			local boost = character:GetBoosts()
			local bFirst = true

			for k, v in SortedPairsByMemberValue(ix.attributes.list, "name") do
				local attributeBoost = 0

				if (boost[k]) then
					for _, bValue in pairs(boost[k]) do
						attributeBoost = attributeBoost + bValue
					end
				end

				local bar = self.attributes:Add("ixAttributeBar")
				bar:Dock(TOP)

				if (!bFirst) then
					bar:DockMargin(0, 3, 0, 0)
				else
					bFirst = false
				end

				local value = character:GetAttribute(k, 0)

				if (attributeBoost) then
					bar:SetValue(value - attributeBoost or 0)
				else
					bar:SetValue(value)
				end

				local maximum = v.maxValue or ix.config.Get("maxAttributes", 30)
				bar:SetMax(maximum)
				bar:SetReadOnly()
				bar:SetText(Format("%s [%.1f/%.1f] (%.1f%%)", L(v.name), value, maximum, value / maximum * 100))

				if (attributeBoost) then
					bar:SetBoost(attributeBoost)
				end
			end

			self.attributes:SizeToContents()
		end
	end

	hook.Run("CreateCharacterInfoCategory", self)
end

function PANEL:Update(character)
	if (!character) then
		return
	end

	local faction = ix.faction.indices[character:GetFaction()]
	local class = ix.class.list[character:GetClass()]

	if (self.name) then
		self.name:SetText(character:GetName())

		if (faction) then
			self.name.backgroundColor = ColorAlpha(faction.color, 150) or Color(0, 0, 0, 150)
		end

		self.name:SizeToContents()
	end

	if (self.description) then
		self.description:SetText(character:GetDescription())
		self.description:SizeToContents()
	end

	if (self.faction) then
		self.faction:SetLabelText(L("faction"))
		self.faction:SetText(L(faction.name))
		self.faction:SizeToContents()
	end

	if (self.class) then
		-- don't show class label if the class is the same name as the faction
		if (class and class.name != faction.name) then
			self.class:SetLabelText(L("class"))
			self.class:SetText(L(class.name))
			self.class:SizeToContents()
		else
			self.class:SetVisible(false)
		end
	end

	if (self.money) then
		self.money:SetLabelText(L("money"))
		self.money:SetText(ix.currency.Get(character:GetMoney()))
		self.money:SizeToContents()
	end

	hook.Run("UpdateCharacterInfo", self.characterInfo, character)

	self.characterInfo:SizeToContents()

	hook.Run("UpdateCharacterInfoCategory", self, character)
end

function PANEL:OnSubpanelRightClick()
	properties.OpenEntityMenu(LocalPlayer())
end

vgui.Register("ixCharacterInfo", PANEL, "DScrollPanel")

hook.Add("CreateMenuButtons", "ixCharInfo", function(tabs)
	tabs["you"] = {
		bHideBackground = true,
		buttonColor = team.GetColor(LocalPlayer():Team()),
		Create = function(info, container)
			container.infoPanel = container:Add("ixCharacterInfo")

			container.OnMouseReleased = function(this, key)
				if (key == MOUSE_RIGHT) then
					this.infoPanel:OnSubpanelRightClick()
				end
			end
		end,
		OnSelected = function(info, container)
			container.infoPanel:Update(LocalPlayer():GetCharacter())
			ix.gui.menu:SetCharacterOverview(true)
		end,
		OnDeselected = function(info, container)
			ix.gui.menu:SetCharacterOverview(false)
		end
	}
end)
